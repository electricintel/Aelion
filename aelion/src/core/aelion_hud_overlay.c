#include <stdio.h>
#include <string.h>
#include <windows.h>
#include "aelion_hud_overlay.h"
#include "aelion_hud_anim.h"

static char g_phase[64] = "IDLE";
static long g_current = 0;
static long g_total = 0;

void hud_overlay_set(const char *phase, long current, long total) {
    strncpy(g_phase, phase, sizeof(g_phase)-1);
    g_current = current;
    g_total = total;

    hud_anim_tick();

    printf("\r\x1b[36m[HUD]\x1b[0m %-12s %s | \x1b[34mFiles:\x1b[0m %ld / %ld | %s",
           g_phase,
           hud_anim_spinner(),
           g_current,
           g_total,
           hud_anim_cycle());

    fflush(stdout);
}

void hud_overlay_message(const char *msg) {
    hud_anim_tick();
    printf("\r\x1b[36m[HUD]\x1b[0m %-12s %s | %s\n",
           g_phase,
           hud_anim_wave(),
           msg);
    fflush(stdout);
}

void hud_overlay_clear(void) {
    printf("\r\x1b[36m[HUD]\x1b[0m READY          \n");
    fflush(stdout);
}
