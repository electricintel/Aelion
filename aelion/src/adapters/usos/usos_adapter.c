#include \"usos_adapter.h\"
#include <stdio.h>

void usos_send(const char* message) {
    printf(\"[USOS] Sending: %s\\n\", message);
}

void usos_receive() {
    printf(\"[USOS] Receiving message...\\n\");
}
