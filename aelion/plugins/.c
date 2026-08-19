#include <stdio.h>
#include "aelion_db.h"

__declspec(dllexport)
void aelion_plugin_entry(aelion_db_t *db, const char *cmd) {
    printf("\x1b[35m[ PLUGIN] Command: %s\x1b[0m\n", cmd);
}
