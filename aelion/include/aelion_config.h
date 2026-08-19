#ifndef AELION_CONFIG_H
#define AELION_CONFIG_H

typedef struct {
    char root[256];
    char throttle[32];
    char watcher[32];
    char hud_color[32];
} aelion_config_t;

extern aelion_config_t AELION_CONFIG;

int aelion_config_load(const char *path);
int aelion_config_save(const char *path);

#endif
