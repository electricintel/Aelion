#include "security.h"
#include <stdio.h>
#include <string.h>

int security_check(const char* intent) {
    if (strcmp(intent, "mining.start") == 0)
        return 0;
    return 1;
}
