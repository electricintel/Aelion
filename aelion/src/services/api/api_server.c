#if !defined(_WIN32)
#define _POSIX_C_SOURCE 200809L
#endif

#include "api_server.h"

#include "../../core/bus/bus.h"
#include "../../core/security/security.h"
#include "../../core/usp/usp.h"

#include <stdio.h>
#include <signal.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#if !defined(_WIN32)
#include <pthread.h>
#endif

#if defined(_WIN32) || defined(__CYGWIN__)
#if defined(_WIN32)
#include <direct.h>
#include <io.h>
#else
#include <sys/stat.h>
#endif
#include <winsock2.h>
#include <ws2tcpip.h>
typedef SOCKET socket_handle;
#define CLOSE_SOCKET closesocket
#define SOCKET_ERROR_CODE WSAGetLastError()
#define SOCKET_PROTOCOL IPPROTO_TCP
#else
#include <arpa/inet.h>
#include <errno.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <unistd.h>
#include <fcntl.h>
typedef int socket_handle;
#define INVALID_SOCKET (-1)
#define CLOSE_SOCKET close
#define SOCKET_ERROR_CODE errno
#define SOCKET_PROTOCOL 0
#endif

#define REQUEST_LIMIT 8192
#define RESPONSE_LIMIT 16384
#define DEFAULT_TOKEN "aelion-local-token"
#define DEFAULT_DATA_DIR "data"
#define MAX_BODY_SIZE 4096
#define REQUEST_TIMEOUT_SECONDS 10

#if !defined(_WIN32)
static volatile sig_atomic_t shutdown_requested = 0;

static void request_shutdown(int signal_number) {
    (void)signal_number;
    shutdown_requested = 1;
}
#endif

typedef struct {
    unsigned long requests;
    unsigned long authorized;
    unsigned long rejected;
    unsigned long errors;
    char last_event[512];
    char journal_path[1024];
} ApiMetrics;

typedef struct {
    socket_handle client;
    const char *token;
    ApiMetrics *metrics;
} ClientJob;

#if !defined(_WIN32)
static pthread_mutex_t metrics_lock = PTHREAD_MUTEX_INITIALIZER;
#endif

static void load_journal(ApiMetrics *metrics) {
    FILE *journal = fopen(metrics->journal_path, "r");
    char line[768];
    if (!journal) return;
    while (fgets(line, sizeof(line), journal)) {
        char *separator = strchr(line, '\t');
        char *event = separator ? separator + 1 : line;
        size_t length = strlen(event);
        if (separator) *separator = '\0';
        while (length > 0 && (event[length - 1] == '\n' || event[length - 1] == '\r')) event[--length] = '\0';
        if (!separator || event[0] == '\0') continue;
        metrics->requests++;
        metrics->authorized++;
        snprintf(metrics->last_event, sizeof(metrics->last_event), "%s", event);
    }
    fclose(journal);
}

static int append_journal(const ApiMetrics *metrics, const char *event) {
    FILE *journal = fopen(metrics->journal_path, "a");
    int result;
    if (!journal) return 0;
    result = fprintf(journal, "%lu\t%s\n", (unsigned long)time(NULL), event) > 0;
    if (result && fflush(journal) != 0) result = 0;
#if defined(_WIN32)
    if (result && _commit(_fileno(journal)) != 0) result = 0;
#elif defined(__unix__) && !defined(__CYGWIN__)
    if (result && fsync(fileno(journal)) != 0) result = 0;
#endif
    fclose(journal);
    return result;
}

static void ensure_data_dir(const char *path) {
#if defined(_WIN32)
    _mkdir(path);
#else
    mkdir(path, 0750);
#endif
}

static int send_all(socket_handle client, const char *data, size_t length) {
    size_t sent = 0;
    while (sent < length) {
        int result = send(client, data + sent, (int)(length - sent), 0);
        if (result <= 0) return 0;
        sent += (size_t)result;
    }
    return 1;
}

static int receive_request(socket_handle client, char *buffer, size_t capacity) {
    int received = 0;
    int chunk;
    size_t expected = 0;
    const char *headers_end = NULL;
    const char *length_header;

    do {
        chunk = recv(client, buffer + received, (int)(capacity - (size_t)received - 1), 0);
        if (chunk <= 0) return received;
        received += chunk;
        buffer[received] = '\0';
        if ((size_t)received >= capacity - 1) return -1;
        headers_end = strstr(buffer, "\r\n\r\n");
        if (headers_end) {
            length_header = strstr(buffer, "Content-Length:");
            if (length_header) expected = (size_t)strtoul(length_header + 15, NULL, 10);
            expected += (size_t)(headers_end + 4 - buffer);
        }
    } while (!headers_end || (size_t)received < expected);
    return received;
}

static void json_escape(const char *input, char *output, size_t capacity) {
    size_t used = 0;
    while (*input && used + 2 < capacity) {
        unsigned char ch = (unsigned char)*input++;
        if (ch == '"' || ch == '\\') {
            if (used + 2 >= capacity) break;
            output[used++] = '\\';
            output[used++] = (char)ch;
        } else if (ch == '\n' || ch == '\r') {
            output[used++] = ' ';
        } else {
            output[used++] = (char)ch;
        }
    }
    output[used] = '\0';
}

static int json_value(const char *json, const char *key, char *value, size_t capacity) {
    char marker[96];
    const char *start;
    size_t length = 0;

    snprintf(marker, sizeof(marker), "\"%s\"", key);
    start = strstr(json, marker);
    if (!start) return 0;
    start = strchr(start + strlen(marker), ':');
    if (!start) return 0;
    start++;
    while (*start == ' ' || *start == '\t') start++;
    if (*start != '"') return 0;
    start++;
    while (start[length] && start[length] != '"' && length + 1 < capacity) {
        if (start[length] == '\\' && start[length + 1]) length++;
        value[length] = start[length];
        length++;
    }
    value[length] = '\0';
    return 1;
}

static void http_response(socket_handle client, int status, const char *type, const char *body) {
    char header[512];
    const char *reason = status == 200 ? "OK" : status == 201 ? "Created" : status == 401 ? "Unauthorized" : status == 404 ? "Not Found" : status == 405 ? "Method Not Allowed" : status == 413 ? "Payload Too Large" : status == 503 ? "Service Unavailable" : "Bad Request";
    int length = snprintf(header, sizeof(header),
        "HTTP/1.1 %d %s\r\nContent-Type: %s\r\nContent-Length: %zu\r\nConnection: close\r\nAccess-Control-Allow-Origin: *\r\n\r\n",
        status, reason, type, strlen(body));
    send_all(client, header, (size_t)length);
    send_all(client, body, strlen(body));
}

static int authorized(const char *request, const char *token) {
    const char *header = strstr(request, "\r\nAuthorization:");
    if (!header) header = strstr(request, "\r\nauthorization:");
    if (!header) header = strstr(request, "\nAuthorization:");
    if (!header) header = strstr(request, "\nauthorization:");
    size_t token_length = strlen(token);
    if (!header) {
        if (strncmp(request, "Authorization:", 14) == 0 || strncmp(request, "authorization:", 14) == 0) header = request;
        else return 0;
    }
    if (*header == '\r') header++;
    if (*header == '\n') header++;
    header += 14;
    while (*header == ' ' || *header == '\t') header++;
    if (strncmp(header, "Bearer ", 7) != 0) return 0;
    header += 7;
    return strncmp(header, token, token_length) == 0 &&
        (header[token_length] == '\r' || header[token_length] == '\n' || header[token_length] == '\0');
}

static void handle_request(socket_handle client, const char *request, const char *token, ApiMetrics *metrics) {
    char method[16] = {0};
    char path[256] = {0};
    char body[REQUEST_LIMIT] = {0};
    char escaped[1024];
    char response[RESPONSE_LIMIT];
    char raw[512] = {0};
    const char *body_start;

    metrics->requests++;
    sscanf(request, "%15s %255s", method, path);
    body_start = strstr(request, "\r\n\r\n");
    if (body_start) strncpy(body, body_start + 4, sizeof(body) - 1);

    if (body_start && strlen(body) > MAX_BODY_SIZE) {
        metrics->errors++;
        http_response(client, 413, "application/json", "{\"error\":\"request_too_large\"}");
        return;
    }

    if (strcmp(path, "/health") == 0 || strcmp(path, "/api/v1/health") == 0) {
        snprintf(response, sizeof(response), "{\"status\":\"ok\",\"service\":\"aelion\",\"authenticated\":%s}", authorized(request, token) ? "true" : "false");
        http_response(client, 200, "application/json", response);
        return;
    }

    if (!authorized(request, token)) {
        metrics->rejected++;
        http_response(client, 401, "application/json", "{\"error\":\"authentication_required\",\"message\":\"Use Authorization: Bearer <token>\"}");
        return;
    }
    metrics->authorized++;

    if (strcmp(path, "/api/v1/metrics") == 0) {
        json_escape(metrics->last_event, escaped, sizeof(escaped));
        snprintf(response, sizeof(response), "{\"requests\":%lu,\"authorized\":%lu,\"rejected\":%lu,\"errors\":%lu,\"last_event\":\"%s\"}", metrics->requests, metrics->authorized, metrics->rejected, metrics->errors, escaped);
        http_response(client, 200, "application/json", response);
        return;
    }

    if (strcmp(path, "/api/v1/events") == 0) {
        json_escape(metrics->last_event, escaped, sizeof(escaped));
        snprintf(response, sizeof(response), "{\"events\":[{\"message\":\"%s\"}]}", escaped);
        http_response(client, 200, "application/json", response);
        return;
    }

    if (strcmp(path, "/api/v1/requests") == 0 && strcmp(method, "POST") == 0) {
        if (!json_value(body, "request", raw, sizeof(raw))) json_value(body, "intent", raw, sizeof(raw));
        if (raw[0] == '\0') {
            metrics->errors++;
            http_response(client, 400, "application/json", "{\"error\":\"invalid_request\",\"message\":\"JSON field request or intent is required\"}");
            return;
        }
        Sentence sentence = usp_parse(raw);
        if (!security_check(sentence.intent)) {
            metrics->errors++;
            http_response(client, 403, "application/json", "{\"error\":\"blocked_intent\"}");
            return;
        }
        bus_publish(&sentence);
        bus_route(&sentence);
        snprintf(metrics->last_event, sizeof(metrics->last_event), "%s", raw);
        if (!append_journal(metrics, raw)) {
            metrics->errors++;
            http_response(client, 503, "application/json", "{\"error\":\"persistence_unavailable\"}");
            return;
        }
        json_escape(raw, escaped, sizeof(escaped));
        snprintf(response, sizeof(response), "{\"accepted\":true,\"request\":\"%s\",\"intent\":\"%s\",\"timestamp\":%lu}", escaped, sentence.intent, (unsigned long)time(NULL));
        http_response(client, 201, "application/json", response);
        return;
    }

    if (strcmp(path, "/api/v1/requests") == 0) {
        http_response(client, 405, "application/json", "{\"error\":\"method_not_allowed\"}");
        return;
    }
    http_response(client, 404, "application/json", "{\"error\":\"not_found\"}");
}

#if !defined(_WIN32)
static void *serve_client(void *argument) {
    ClientJob *job = (ClientJob *)argument;
    char request[REQUEST_LIMIT];
    int received;

    received = receive_request(job->client, request, sizeof(request));
    pthread_mutex_lock(&metrics_lock);
    if (received < 0) {
        http_response(job->client, 413, "application/json", "{\"error\":\"request_too_large\"}");
    } else if (received > 0) {
        request[received] = '\0';
        handle_request(job->client, request, job->token, job->metrics);
    }
    pthread_mutex_unlock(&metrics_lock);
    CLOSE_SOCKET(job->client);
    free(job);
    return NULL;
}
#endif

int api_server_run(const char *host, unsigned short port, const char *token, const char *data_dir) {
    socket_handle server;
    struct sockaddr_in address;
    ApiMetrics metrics = {0};
    const char *effective_token = token && token[0] ? token : DEFAULT_TOKEN;
    const char *effective_data_dir = data_dir && data_dir[0] ? data_dir : DEFAULT_DATA_DIR;

#if !defined(_WIN32)
    signal(SIGINT, request_shutdown);
    signal(SIGTERM, request_shutdown);
#endif

    ensure_data_dir(effective_data_dir);
    snprintf(metrics.journal_path, sizeof(metrics.journal_path), "%s/events.log", effective_data_dir);
    load_journal(&metrics);

#if defined(_WIN32) || defined(__CYGWIN__)
    WSADATA winsock;
    if (WSAStartup(MAKEWORD(2, 2), &winsock) != 0) {
        fprintf(stderr, "[API] WSAStartup failed: %d\n", SOCKET_ERROR_CODE);
        return 1;
    }
#endif
    server = socket(AF_INET, SOCK_STREAM, SOCKET_PROTOCOL);
    if (server == INVALID_SOCKET) {
        fprintf(stderr, "[API] socket failed: %d\n", SOCKET_ERROR_CODE);
        return 1;
    }
    memset(&address, 0, sizeof(address));
    address.sin_family = AF_INET;
    address.sin_port = htons(port);
    address.sin_addr.s_addr = inet_addr(host && host[0] ? host : "127.0.0.1");
    if (bind(server, (struct sockaddr *)&address, sizeof(address)) < 0 || listen(server, 16) < 0) {
        fprintf(stderr, "[API] bind/listen failed on port %u: %d\n", port, SOCKET_ERROR_CODE);
        CLOSE_SOCKET(server);
        return 1;
    }
    printf("[API] Listening on http://%s:%u (token authentication enabled)\n", host && host[0] ? host : "127.0.0.1", port);
    while (!shutdown_requested) {
        socket_handle client = accept(server, NULL, NULL);
        if (client == INVALID_SOCKET) continue;
#if defined(_WIN32) || defined(__CYGWIN__)
        {
            DWORD timeout = REQUEST_TIMEOUT_SECONDS * 1000;
            setsockopt(client, SOL_SOCKET, SO_RCVTIMEO, (const char *)&timeout, sizeof(timeout));
        }
#else
        {
            struct timeval timeout = { REQUEST_TIMEOUT_SECONDS, 0 };
            setsockopt(client, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
        }
#endif
#if !defined(_WIN32)
        {
            ClientJob *job = (ClientJob *)malloc(sizeof(ClientJob));
            pthread_t worker;
            if (!job) {
                CLOSE_SOCKET(client);
                continue;
            }
            job->client = client;
            job->token = effective_token;
            job->metrics = &metrics;
            if (pthread_create(&worker, NULL, serve_client, job) != 0) {
                free(job);
                CLOSE_SOCKET(client);
                continue;
            }
            pthread_detach(worker);
        }
#else
        {
            char request[REQUEST_LIMIT];
            int received = receive_request(client, request, sizeof(request));
            if (received < 0) {
                http_response(client, 413, "application/json", "{\"error\":\"request_too_large\"}");
            } else if (received > 0) {
                request[received] = '\0';
                handle_request(client, request, effective_token, &metrics);
            }
        }
        CLOSE_SOCKET(client);
#endif
    }
    CLOSE_SOCKET(server);
#if defined(_WIN32) || defined(__CYGWIN__)
    WSACleanup();
#endif
    return 0;
}
