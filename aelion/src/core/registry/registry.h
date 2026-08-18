#ifndef REGISTRY_H
#define REGISTRY_H

typedef struct {
    char engine_name[64];
    int healthy;
} EngineRecord;

void registry_register(const char* engine);
EngineRecord registry_health(const char* engine);

#endif
