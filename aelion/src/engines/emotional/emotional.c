#include "emotional.h"
#include <stdio.h>

void emotional_analyze(const Sentence* s) {
    printf("[EMOTIONAL] Analyzing tone for: %s\n", s->payload);
}
