#include "usp.h"
#include <stdio.h>
#include <string.h>

Sentence usp_parse(const char* raw) {
    Sentence s;
    memset(&s, 0, sizeof(Sentence));
    strncpy(s.payload, raw, sizeof(s.payload)-1);
    return s;
}

void usp_serialize(const Sentence* s, char* out) {
    snprintf(out, 512, "%s|%s|%s|%s|%s|%s",
        s->id, s->timestamp, s->source,
        s->target_engine, s->intent, s->payload);
}
