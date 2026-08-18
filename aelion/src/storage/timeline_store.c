#include "timeline_store.h"
#include <stdio.h>
#include <string.h>

static char timeline[10][256];
static int timeline_index = 0;

void timeline_add(const char* event) {
    if (timeline_index < 10) {
        strncpy(timeline[timeline_index], event, sizeof(timeline[timeline_index])-1);
        timeline_index++;
    }
    printf("[TIMELINE] Added event: %s\n", event);
}

void timeline_dump() {
    printf("[TIMELINE] Dumping events:\n");
    for (int i = 0; i < timeline_index; i++) {
        printf("  - %s\n", timeline[i]);
    }
}
