#include <stdio.h>
#include \"../../src/core/bus/bus.h\"

int main() {
    Sentence s;
    snprintf(s.intent, sizeof(s.intent), \"test.intent\");
    bus_publish(&s);
    bus_route(&s);
    return 0;
}
