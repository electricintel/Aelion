#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "core/bus/bus.h"
#include "core/security/security.h"
#include "core/usp/usp.h"
#include "services/api/api_server.h"

int main(int argc, char **argv) {
    if (argc > 1 && strcmp(argv[1], "--serve") == 0) {
        unsigned short port = 8080;
        const char *token = getenv("AELION_API_TOKEN");
        const char *host = getenv("AELION_API_HOST");
        const char *data_dir = getenv("AELION_DATA_DIR");
        const char *port_value = getenv("AELION_API_PORT");
        const char *environment = getenv("AELION_ENV");
        if (argc > 2) port_value = argv[2];
        if (port_value && port_value[0]) port = (unsigned short)strtoul(port_value, NULL, 10);
        if (environment && strcmp(environment, "production") == 0 && (!token || !token[0])) {
            fprintf(stderr, "[AELION] AELION_API_TOKEN is required in production.\n");
            return 2;
        }
        return api_server_run(host && host[0] ? host : "127.0.0.1", port, token, data_dir);
    }
    const char *input = argc > 1 ? argv[1] : "system.check";
    Sentence sentence = usp_parse(input);
    char serialized[512];

    if (!security_check(sentence.intent)) {
        fprintf(stderr, "[AELION] blocked intent: %s\n", sentence.intent);
        return 2;
    }

    bus_publish(&sentence);
    bus_route(&sentence);
    usp_serialize(&sentence, serialized);
    printf("[AELION] %s\n", serialized);
    return 0;
}