#include <stdio.h>
#include \"../../src/core/usp/usp.h\"

int main() {
    Sentence s = usp_parse(\"test payload\");
    printf(\"[TEST_USP] Payload: %s\\n\", s.payload);
    return 0;
}
