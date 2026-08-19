#include <stdio.h>
#include "aelion_dupes.h"
#include "aelion_hud.h"
#include "aelion_db.h"

int aelion_dupes_scan(aelion_db_t *db) {
    sqlite3_stmt *stmt = NULL;

    const char *sql =
        "SELECT hash, COUNT(*) AS cnt "
        "FROM fs_items "
        "WHERE hash IS NOT NULL AND hash <> '' "
        "GROUP BY hash "
        "HAVING cnt > 1;";

    if (aelion_db_prepare(db, sql, &stmt) != SQLITE_OK)
        return 1;

    int totalDupGroups = 0;

    while (sqlite3_step(stmt) == SQLITE_ROW) {
        const unsigned char *hash = sqlite3_column_text(stmt, 0);
        int cnt = sqlite3_column_int(stmt, 1);

        printf("\n[DUPES] Hash: %s (count=%d)\n", hash, cnt);

        sqlite3_stmt *stmtFiles = NULL;
        const char *sqlFiles =
            "SELECT path, size_bytes "
            "FROM fs_items "
            "WHERE hash = ?;";

        if (aelion_db_prepare(db, sqlFiles, &stmtFiles) != SQLITE_OK)
            continue;

        sqlite3_bind_text(stmtFiles, 1, (const char *)hash, -1, SQLITE_TRANSIENT);

        while (sqlite3_step(stmtFiles) == SQLITE_ROW) {
            const unsigned char *path = sqlite3_column_text(stmtFiles, 0);
            sqlite3_int64 size = sqlite3_column_int64(stmtFiles, 1);

            printf("    %lld bytes  %s\n", (long long)size, path);
        }

        sqlite3_finalize(stmtFiles);
        totalDupGroups++;
    }

    sqlite3_finalize(stmt);

    char msg[128];
    snprintf(msg, sizeof(msg), "Duplicate scan complete: %d groups", totalDupGroups);
    aelion_hud_log(db, HUD_INFO, msg);

    return 0;
}
