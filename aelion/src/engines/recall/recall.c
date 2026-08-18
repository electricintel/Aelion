#include "recall.h"
#include <stdio.h>

void recall_store(const Sentence* s) {
    printf("[RECALL] Stored event: %s\n", s->payload);
}

void recall_query(const char* criteria) {
    printf("[RECALL] Query timeline: %s\n", criteria);
}
