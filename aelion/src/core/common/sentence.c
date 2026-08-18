#include "sentence.h"
#include <string.h>

void set_sentence(RawSentence* s, const char* text) {
    strncpy(s->text, text, sizeof(s->text)-1);
}
