#include <stdio.h>
#include <string.h>
#include "core/usp/usp.h"

int main() {
    Sentence s = usp_parse("justice.review");
    if (strcmp(s.intent, "justice.review") != 0 || strcmp(s.target_engine, "justice") != 0) {
        fprintf(stderr, "[TEST_USP] Structured intent parsing failed.\n");
        return 1;
    }
    printf("[TEST_USP] Payload: %s\n", s.payload);
    return 0;
}
