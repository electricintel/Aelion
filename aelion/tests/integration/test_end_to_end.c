#include <stdio.h>
#include \"../../src/core/usp/usp.h\"
#include \"../../src/core/bus/bus.h\"

int main() {
    Sentence s = usp_parse(\"integration test payload\");
    bus_publish(&s);
    bus_route(&s);
    printf(\"[TEST_E2E] End-to-end test completed.\\n\");
    return 0;
}
