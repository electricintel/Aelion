#include "api_server.h"

#include "../../core/bus/bus.h"
#include "../../core/security/security.h"
#include "../../core/usp/usp.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#if defined(_WIN32) || defined(__CYGWIN__)
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
#include <unistd.h>
typedef int socket_handle;
#define INVALID_SOCKET (-1)
#define CLOSE_SOCKET close
#define SOCKET_ERROR_CODE errno
#define SOCKET_PROTOCOL 0
#endif

#define REQUEST_LIMIT 8192
#define RESPONSE_LIMIT 16384
#define DEFAULT_TOKEN "aelion-local-token"

typedef struct {
    unsigned long requests;
    unsigned long authorized;
    unsigned long rejected;
    unsigned long errors;
    char last_event[512];
} ApiMetrics;

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
    const char *reason = status == 200 ? "OK" : status == 201 ? "Created" : status == 401 ? "Unauthorized" : status == 404 ? "Not Found" : "Bad Request";
    int length = snprintf(header, sizeof(header),
        "HTTP/1.1 %d %s\r\nContent-Type: %s\r\nContent-Length: %zu\r\nConnection: close\r\nAccess-Control-Allow-Origin: *\r\n\r\n",
        status, reason, type, strlen(body));
    send_all(client, header, (size_t)length);
    send_all(client, body, strlen(body));
}

static int authorized(const char *request, const char *token) {
    char expected[256];
    snprintf(expected, sizeof(expected), "Authorization: Bearer %s", token);
    return strstr(request, expected) != NULL;
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
        json_escape(raw, escaped, sizeof(escaped));
        snprintf(response, sizeof(response), "{\"accepted\":true,\"request\":\"%s\",\"intent\":\"%s\",\"timestamp\":%lu}", escaped, sentence.intent, (unsigned long)time(NULL));
        http_response(client, 201, "application/json", response);
        return;
    }

    http_response(client, 404, "application/json", "{\"error\":\"not_found\"}");
}

int api_server_run(const char *host, unsigned short port, const char *token) {
    socket_handle server;
    struct sockaddr_in address;
    ApiMetrics metrics = {0};
    const char *effective_token = token && token[0] ? token : DEFAULT_TOKEN;

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
    for (;;) {
        socket_handle client = accept(server, NULL, NULL);
        char request[REQUEST_LIMIT];
        int received;
        if (client == INVALID_SOCKET) continue;
        received = receive_request(client, request, sizeof(request));
        if (received > 0) {
            request[received] = '\0';
            handle_request(client, request, effective_token, &metrics);
        }
        CLOSE_SOCKET(client);
    }
    CLOSE_SOCKET(server);
#if defined(_WIN32) || defined(__CYGWIN__)
    WSACleanup();
#endif
    return 0;
}
