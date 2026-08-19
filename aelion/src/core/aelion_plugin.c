#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <windows.h>
#include "aelion_plugin.h"
#include "aelion_hud.h"

#define MAX_PLUGINS 64
static aelion_plugin_t plugins[MAX_PLUGINS];
static int plugin_count = 0;

static aelion_plugin_t* find_plugin(const char *name) {
    for (int i = 0; i < plugin_count; i++)
        if (strcmp(plugins[i].name, name) == 0)
            return &plugins[i];
    return NULL;
}

int aelion_plugin_load(const char *name) {
    if (find_plugin(name)) {
        printf("\x1b[33m[PLUGIN] Already loaded: %s\x1b[0m\n", name);
        return 1;
    }

    char dllPath[256];
    snprintf(dllPath, sizeof(dllPath), "plugins/%s.dll", name);

    HMODULE h = LoadLibraryA(dllPath);
    if (!h) {
        printf("\x1b[31m[PLUGIN] Failed to load %s\x1b[0m\n", dllPath);
        return 1;
    }

    void (*entry)(aelion_db_t*, const char*) =
        (void (*)(aelion_db_t*, const char*))GetProcAddress(h, "aelion_plugin_entry");

    if (!entry) {
        printf("\x1b[31m[PLUGIN] Missing entry() in %s\x1b[0m\n", dllPath);
        FreeLibrary(h);
        return 1;
    }

    aelion_plugin_t *p = &plugins[plugin_count++];
    strncpy(p->name, name, sizeof(p->name)-1);
    strncpy(p->path, dllPath, sizeof(p->path)-1);
    p->handle = h;
    p->entry = entry;

    printf("\x1b[32m[PLUGIN] Loaded: %s\x1b[0m\n", name);
    return 0;
}

int aelion_plugin_unload(const char *name) {
    aelion_plugin_t *p = find_plugin(name);
    if (!p) {
        printf("\x1b[31m[PLUGIN] Not loaded: %s\x1b[0m\n", name);
        return 1;
    }

    FreeLibrary(p->handle);

    for (int i = 0; i < plugin_count; i++) {
        if (&plugins[i] == p) {
            plugins[i] = plugins[plugin_count - 1];
            plugin_count--;
            break;
        }
    }

    printf("\x1b[32m[PLUGIN] Unloaded: %s\x1b[0m\n", name);
    return 0;
}

void aelion_plugin_list(void) {
    printf("\n\x1b[36m=== LOADED PLUGINS ===\x1b[0m\n");
    for (int i = 0; i < plugin_count; i++)
        printf("%s\t%s\n", plugins[i].name, plugins[i].path);
}

int aelion_plugin_call(aelion_db_t *db, const char *name, const char *cmd) {
    aelion_plugin_t *p = find_plugin(name);
    if (!p) {
        printf("\x1b[31m[PLUGIN] Not loaded: %s\x1b[0m\n", name);
        return 1;
    }

    p->entry(db, cmd);
    return 0;
}
