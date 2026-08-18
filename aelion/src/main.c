#include <stdio.h>

#include "core/bus/bus.h"
#include "core/security/security.h"
#include "core/usp/usp.h"

int main(int argc, char **argv) {
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