#include <stdio.h>
#include "aelion_hud_anim.h"

static int tick = 0;

void hud_anim_tick(void) {
    tick++;
}

const char* hud_anim_spinner(void) {
    static const char* frames[] = { "|", "/", "-", "\\" };
    return frames[tick % 4];
}

const char* hud_anim_wave(void) {
    static const char* frames[] = { "·", "•", "?", "•" };
    return frames[tick % 4];
}

const char* hud_anim_pulse(void) {
    static const char* frames[] = {
        "\x1b[31m?\x1b[0m",
        "\x1b[33m?\x1b[0m",
        "\x1b[32m?\x1b[0m",
        "\x1b[36m?\x1b[0m"
    };
    return frames[tick % 4];
}

const char* hud_anim_cycle(void) {
    static const char* frames[] = {
        "\x1b[31mLIVE\x1b[0m",
        "\x1b[33mLIVE\x1b[0m",
        "\x1b[32mLIVE\x1b[0m",
        "\x1b[36mLIVE\x1b[0m"
    };
    return frames[tick % 4];
}
