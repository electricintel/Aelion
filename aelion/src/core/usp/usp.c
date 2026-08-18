#include "usp.h"
#include <stdio.h>
#include <string.h>

static void append_field(char *out, size_t capacity, size_t *used, const char *field) {
    size_t available;
    size_t length;

    if (*used >= capacity - 1) return;
    available = capacity - *used - 1;
    length = strlen(field);
    if (length > available) length = available;
    memcpy(out + *used, field, length);
    *used += length;
    out[*used] = '\0';
}

Sentence usp_parse(const char* raw) {
    Sentence s;
    const char *separator;
    size_t engine_length;
    memset(&s, 0, sizeof(Sentence));
    strncpy(s.payload, raw, sizeof(s.payload)-1);
    strncpy(s.intent, raw, sizeof(s.intent) - 1);
    separator = strchr(raw, '.');
    if (separator && separator != raw) {
        engine_length = (size_t)(separator - raw);
        if (engine_length >= sizeof(s.target_engine)) engine_length = sizeof(s.target_engine) - 1;
        memcpy(s.target_engine, raw, engine_length);
        s.target_engine[engine_length] = '\0';
    }
    return s;
}

void usp_serialize(const Sentence* s, char* out) {
    size_t used = 0;
    out[0] = '\0';
    append_field(out, 512, &used, s->id);
    append_field(out, 512, &used, "|");
    append_field(out, 512, &used, s->timestamp);
    append_field(out, 512, &used, "|");
    append_field(out, 512, &used, s->source);
    append_field(out, 512, &used, "|");
    append_field(out, 512, &used, s->target_engine);
    append_field(out, 512, &used, "|");
    append_field(out, 512, &used, s->intent);
    append_field(out, 512, &used, "|");
    append_field(out, 512, &used, s->payload);
}
