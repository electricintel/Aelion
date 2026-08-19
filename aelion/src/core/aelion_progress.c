#include <windows.h>
#include <stdio.h>
#include "aelion_progress.h"
#include "aelion_hud_anim.h"

static long g_total = 0;
static int g_throttle_mode = 0;

void aelion_progress_init(long total) {
    g_total = total;
    printf("\x1b[32m[SCAN] Total items: %ld\x1b[0m\n", total);
}

void aelion_progress_update(long current) {
    if (g_total == 0) return;

    hud_anim_tick();

    int width = 50;
    float ratio = (float)current / (float)g_total;
    int filled = (int)(ratio * width);

    printf("\r\x1b[32m[");
    for (int i = 0; i < filled; i++) printf("#");
    for (int i = filled; i < width; i++) printf(".");
    printf("]\x1b[0m %ld / %ld %s",
           current,
           g_total,
           hud_anim_pulse());

    fflush(stdout);

    if (g_throttle_mode == 1)
        Sleep(10);
}

void aelion_progress_finish(void) {
    printf("\n\x1b[32m[SCAN] Progress complete.\x1b[0m\n");
}

void aelion_throttle(int mode) {
    g_throttle_mode = mode;
    if (mode == 0)
        printf("\x1b[32m[SCAN] Throttle: FAST mode\x1b[0m\n");
    else
        printf("\x1b[33m[SCAN] Throttle: SLOW mode\x1b[0m\n");
}
