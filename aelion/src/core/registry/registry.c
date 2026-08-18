#include "registry.h"
#include <stdio.h>
#include <string.h>

void registry_register(const char* engine) {
    printf("[REGISTRY] Registered engine: %s\n", engine);
}

EngineRecord registry_health(const char* engine) {
    EngineRecord r;
    strncpy(r.engine_name, engine, sizeof(r.engine_name)-1);
    r.healthy = 1;
    return r;
}
