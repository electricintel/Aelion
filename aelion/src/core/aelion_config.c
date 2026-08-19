#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "aelion_config.h"

aelion_config_t AELION_CONFIG = {
    "C:\\Users\\phili",
    "fast",
    "on",
    "ansi"
};

static void set_field(const char *key, const char *value) {
    if (strcmp(key, "root") == 0)
        strncpy(AELION_CONFIG.root, value, sizeof(AELION_CONFIG.root)-1);
    else if (strcmp(key, "throttle") == 0)
        strncpy(AELION_CONFIG.throttle, value, sizeof(AELION_CONFIG.throttle)-1);
    else if (strcmp(key, "watcher") == 0)
        strncpy(AELION_CONFIG.watcher, value, sizeof(AELION_CONFIG.watcher)-1);
    else if (strcmp(key, "hud_color") == 0)
        strncpy(AELION_CONFIG.hud_color, value, sizeof(AELION_CONFIG.hud_color)-1);
}

int aelion_config_load(const char *path) {
    FILE *f = fopen(path, "r");
    if (!f) return 1;

    char line[512];
    while (fgets(line, sizeof(line), f)) {
        char *eq = strchr(line, '=');
        if (!eq) continue;

        *eq = 0;
        char *key = line;
        char *value = eq + 1;

        key[strcspn(key, "\n")] = 0;
        value[strcspn(value, "\n")] = 0;

        set_field(key, value);
    }

    fclose(f);
    return 0;
}

int aelion_config_save(const char *path) {
    FILE *f = fopen(path, "w");
    if (!f) return 1;

    fprintf(f, "root=%s\n", AELION_CONFIG.root);
    fprintf(f, "throttle=%s\n", AELION_CONFIG.throttle);
    fprintf(f, "watcher=%s\n", AELION_CONFIG.watcher);
    fprintf(f, "hud_color=%s\n", AELION_CONFIG.hud_color);

    fclose(f);
    return 0;
}
