#include "home.h"
#include <stdio.h>

void home_diagnose(const Sentence* s) {
    printf("[HOME] Diagnosing: %s\n", s->payload);
}
