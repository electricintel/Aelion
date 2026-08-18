#include "registry.h"
#include <stdio.h>

void print_engine_health(const char* engine) {
    EngineRecord r = registry_health(engine);
    printf("[HEALTH] Engine %s status: %s\n",
        r.engine_name,
        r.healthy ? "OK" : "FAIL");
}
