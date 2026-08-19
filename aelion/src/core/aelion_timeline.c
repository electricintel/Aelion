#include <stdio.h>
#include <string.h>
#include "aelion_timeline.h"

static void run_timeline_query(aelion_db_t *db, const char *sql) {
    sqlite3_stmt *stmt = NULL;

    if (aelion_db_prepare(db, sql, &stmt) != SQLITE_OK) {
        printf("\x1b[31m[TIMELINE] Query failed\x1b[0m\n");
        return;
    }

    while (sqlite3_step(stmt) == SQLITE_ROW) {
        sqlite3_int64 ts = sqlite3_column_int64(stmt, 0);
        const char *type = (const char *)sqlite3_column_text(stmt, 1);
        const char *detail = (const char *)sqlite3_column_text(stmt, 2);

        printf("%lld\t%-12s\t%s\n", (long long)ts, type, detail ? detail : "");
    }

    sqlite3_finalize(stmt);
}

void aelion_timeline_all(aelion_db_t *db) {
    printf("\n\x1b[36m=== FULL TIMELINE ===\x1b[0m\n");
    run_timeline_query(db,
        "SELECT ts, change_type AS type, path AS detail "
        "FROM fs_changes "
        "UNION ALL "
        "SELECT ts, level AS type, message AS detail "
        "FROM hud_events "
        "ORDER BY ts ASC;");
}

void aelion_timeline_range(aelion_db_t *db, long from_ts, long to_ts) {
    printf("\n\x1b[36m=== TIMELINE RANGE ===\x1b[0m\n");
    char sql[512];
    snprintf(sql, sizeof(sql),
        "SELECT ts, change_type AS type, path AS detail "
        "FROM fs_changes "
        "WHERE ts BETWEEN %ld AND %ld "
        "UNION ALL "
        "SELECT ts, level AS type, message AS detail "
        "FROM hud_events "
        "WHERE ts BETWEEN %ld AND %ld "
        "ORDER BY ts ASC;",
        from_ts, to_ts, from_ts, to_ts);
    run_timeline_query(db, sql);
}

void aelion_timeline_path(aelion_db_t *db, const char *path) {
    printf("\n\x1b[36m=== TIMELINE FOR PATH ===\x1b[0m\n");
    sqlite3_stmt *stmt = NULL;

    const char *sql =
        "SELECT ts, change_type AS type, path AS detail "
        "FROM fs_changes "
        "WHERE path = ? "
        "ORDER BY ts ASC;";

    if (aelion_db_prepare(db, sql, &stmt) != SQLITE_OK) {
        printf("\x1b[31m[TIMELINE] Path query failed\x1b[0m\n");
        return;
    }

    sqlite3_bind_text(stmt, 1, path, -1, SQLITE_TRANSIENT);

    while (sqlite3_step(stmt) == SQLITE_ROW) {
        sqlite3_int64 ts = sqlite3_column_int64(stmt, 0);
        const char *type = (const char *)sqlite3_column_text(stmt, 1);
        const char *detail = (const char *)sqlite3_column_text(stmt, 2);

        printf("%lld\t%-12s\t%s\n", (long long)ts, type, detail ? detail : "");
    }

    sqlite3_finalize(stmt);
}
