#include <stdio.h>
#include <time.h>
#include "aelion_changes.h"
#include "aelion_hud.h"
#include "aelion_db.h"

static void log_change(aelion_db_t *db, const char *path, const char *type,
                       const char *oldHash, const char *newHash) {
    sqlite3_stmt *stmt = NULL;

    const char *sql =
        "INSERT INTO fs_changes (path, change_type, old_hash, new_hash, ts) "
        "VALUES (?, ?, ?, ?, ?);";

    if (aelion_db_prepare(db, sql, &stmt) != SQLITE_OK)
        return;

    sqlite3_bind_text(stmt, 1, path, -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 2, type, -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 3, oldHash ? oldHash : "", -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 4, newHash ? newHash : "", -1, SQLITE_TRANSIENT);
    sqlite3_bind_int64(stmt, 5, (sqlite3_int64)time(NULL));

    sqlite3_step(stmt);
    sqlite3_finalize(stmt);

    char msg[256];
    snprintf(msg, sizeof(msg), "%s: %s", type, path);
    aelion_hud_log(db, HUD_WARN, msg);
}

int aelion_detect_changes(aelion_db_t *db) {
    sqlite3_stmt *stmt = NULL;

    const char *sql =
        "SELECT old.path, old.hash, new.hash "
        "FROM fs_items AS old "
        "LEFT JOIN fs_items AS new ON old.path = new.path "
        "WHERE old.hash <> new.hash OR new.hash IS NULL;";

    if (aelion_db_prepare(db, sql, &stmt) != SQLITE_OK)
        return 1;

    while (sqlite3_step(stmt) == SQLITE_ROW) {
        const char *path = (const char *)sqlite3_column_text(stmt, 0);
        const char *oldHash = (const char *)sqlite3_column_text(stmt, 1);
        const char *newHash = (const char *)sqlite3_column_text(stmt, 2);

        if (newHash == NULL) {
            log_change(db, path, "DELETED", oldHash, NULL);
        } else if (oldHash == NULL) {
            log_change(db, path, "NEW", NULL, newHash);
        } else {
            log_change(db, path, "MODIFIED", oldHash, newHash);
        }
    }

    sqlite3_finalize(stmt);

    aelion_hud_log(db, HUD_INFO, "File change detection complete");
    return 0;
}
