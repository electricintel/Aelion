#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "aelion_plugin_autoload.h"
#include "aelion_plugin.h"

static char *read_file(const char *path) {
    FILE *f = fopen(path, "rb");
    if (!f) return NULL;

    fseek(f, 0, SEEK_END);
    long size = ftell(f);
    rewind(f);

    char *buf = malloc(size + 1);
    fread(buf, 1, size, f);
    buf[size] = '\0';

    fclose(f);
    return buf;
}

static void autoload_from_manifest(aelion_db_t *db) {
    char *json = read_file("plugins/manifest.json");
    if (!json) {
        printf("[AELION] No manifest.json found.\n");
        return;
    }

    char *p = json;

    while ((p = strstr(p, "\"name\"")) != NULL) {
        p = strchr(p, ':');
        if (!p) break;
        p++;

        while (*p == ' ' || *p == '\"') p++;

        char name[128];
        int i = 0;

        while (*p && *p != '\"' && i < 127) {
            name[i++] = *p++;
        }
        name[i] = '\0';

        char *autoFlag = strstr(p, "\"autoload\"");
        int autoload = 0;

        if (autoFlag) {
            char *colon = strchr(autoFlag, ':');
            if (colon) {
                colon++;
                while (*colon == ' ' || *colon == '\"') colon++;
                autoload = (*colon == 't');
            }
        }

        if (autoload) {
            printf("[AELION] Autoload plugin: %s\n", name);
            aelion_plugin_load(name);
        }
    }

    free(json);
}

void aelion_plugins_autoload(aelion_db_t *db) {
    printf("[AELION] Plugin autoload starting...\n");
    autoload_from_manifest(db);
    printf("[AELION] Plugin autoload complete.\n");
}
