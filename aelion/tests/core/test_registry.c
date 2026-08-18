#include <stdio.h>
#include \"../../src/core/registry/registry.h\"

int main() {
    registry_register(\"justice\");
    EngineRecord r = registry_health(\"justice\");
    printf(\"[TEST_REGISTRY] Engine %s healthy=%d\\n\", r.engine_name, r.healthy);
    return 0;
}
