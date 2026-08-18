#include "bus.h"
#include <stdio.h>

void bus_publish(const Sentence* s) {
    printf("[BUS] Published intent: %s\n", s->intent);
}

void bus_route(const Sentence* s) {
    printf("[BUS] Routing to engine: %s\n", s->target_engine);
}
