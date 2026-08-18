#ifndef USP_H
#define USP_H

typedef struct {
    char id[64];
    char timestamp[64];
    char source[64];
    char target_engine[64];
    char intent[128];
    char payload[512];
    float confidence;
} Sentence;

Sentence usp_parse(const char* raw);
void usp_serialize(const Sentence* s, char* out);

#endif
