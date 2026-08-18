#include "security.h"
#include <stdio.h>

void audit_log(const char* message) {
    printf("[AUDIT] %s\n", message);
}
