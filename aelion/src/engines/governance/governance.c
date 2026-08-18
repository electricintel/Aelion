#include "governance.h"
#include <stdio.h>

void governance_filter(const Sentence* s) {
    printf("[GOVERNANCE] Pre-check intent: %s\n", s->intent);
}

void governance_review(const Sentence* s) {
    printf("[GOVERNANCE] Post-check intent: %s\n", s->intent);
}
