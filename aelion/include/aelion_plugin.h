#ifndef AELION_PLUGIN_H
#define AELION_PLUGIN_H

#include <windows.h>
#include "aelion_db.h"

typedef struct {
    char name[128];
    char path[256];
    HMODULE handle;
    void (*entry)(aelion_db_t *db, const char *cmd);
} aelion_plugin_t;

int aelion_plugin_load(const char *name);
int aelion_plugin_unload(const char *name);
void aelion_plugin_list(void);
int aelion_plugin_call(aelion_db_t *db, const char *name, const char *cmd);

#endif
