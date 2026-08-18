#include "justice.h"
#include <stdio.h>

void justice_handle(const Sentence* s) {
    printf("[JUSTICE] Handling intent: %s\n", s->intent);
}
