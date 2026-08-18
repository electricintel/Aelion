#include "community.h"
#include <stdio.h>

void community_plan(const Sentence* s) {
    printf("[COMMUNITY] Planning: %s\n", s->payload);
}
