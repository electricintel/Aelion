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
        if (argc > 2) port = (unsigned short)strtoul(argv[2], NULL, 10);
        return api_server_run("127.0.0.1", port, token);
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