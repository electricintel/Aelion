#include \"kv.h\"
#include <stdio.h>
#include <string.h>

static char last_key[128];
static char last_value[512];

void kv_set(const char* key, const char* value) {
    strncpy(last_key, key, sizeof(last_key)-1);
    strncpy(last_value, value, sizeof(last_value)-1);
    printf(\"[KV] Set %s = %s\\n\", key, value);
}

const char* kv_get(const char* key) {
    if (strcmp(key, last_key) == 0)
        return last_value;
    return \"<undefined>\";
}
