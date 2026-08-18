#include \"scheduler.h\"
#include <stdio.h>

void scheduler_start() {
    printf(\"[SCHEDULER] Started.\\n\");
}

void scheduler_tick() {
    printf(\"[SCHEDULER] Tick event.\\n\");
}
