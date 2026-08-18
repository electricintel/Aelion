#include "cli.h"
#include <stdio.h>

void cli_start() {
    printf(\"AELION CLI HUD started.\\n\");
}

void cli_render(const char* message) {
    printf(\"[HUD] %s\\n\", message);
}
