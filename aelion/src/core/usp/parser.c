#include "usp.h"
#include <string.h>

Sentence parse_sentence(const char* raw) {
    return usp_parse(raw);
}
