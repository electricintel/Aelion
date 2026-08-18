#include "api.h"
#include <stdio.h>

void api_start() {
    printf("[API] Service started. Listening for requests...\n");
}

void api_handle_request(const char* route, const char* payload) {
    printf("[API] Route: %s | Payload: %s\n", route, payload);
}
