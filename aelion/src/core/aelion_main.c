#include <stdio.h>
#include <stdlib.h>
#include "aelion_db.h"
#include "aelion_shell.h"
#include "aelion_hud.h"

static int aelion_db_init(aelion_db_t *db) {
    FILE *f = fopen("src/db/aelion_schema.sql", "rb");
    if (!f) return 1;

    fseek(f, 0, SEEK_END);
    long len = ftell(f);
    fseek(f, 0, SEEK_SET);

    char *buf = malloc(len + 1);
    fread(buf, 1, len, f);
    buf[len] = 0;
    fclose(f);

    int rc = aelion_db_exec(db, buf);
    free(buf);
    return rc != SQLITE_OK;
}

int main(void) {
    aelion_db_t db = {0};

    if (aelion_db_open(&db) != SQLITE_OK)
        return 1;

    if (aelion_db_init(&db) != 0)
        return 1;

    aelion_hud_log(&db, HUD_INFO, "Aelion DB initialized");

    // Launch interactive shell
    aelion_shell(&db);

    aelion_db_close(&db);
    return 0;
}
