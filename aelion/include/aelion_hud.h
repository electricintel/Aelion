#ifndef AELION_HUD_H
#define AELION_HUD_H

#include "aelion_db.h"

typedef enum {
    HUD_INFO,
    HUD_WARN,
    HUD_ERROR
} hud_level_t;

int aelion_hud_log(aelion_db_t *db, hud_level_t level, const char *message);

#endif
