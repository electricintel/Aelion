#include <stdio.h>
#include <string.h>
#include "aelion_dashboard.h"
#include "aelion_hud.h"

static void run_query(aelion_db_t *db, const char *sql) {
    sqlite3_stmt *stmt = NULL;

    if (aelion_db_prepare(db, sql, &stmt) != SQLITE_OK) {
        printf("\x1b[31m[DB] Query failed\x1b[0m\n");
        return;
    }

    int cols = sqlite3_column_count(stmt);

    while (sqlite3_step(stmt) == SQLITE_ROW) {
        for (int i = 0; i < cols; i++) {
            const char *txt = (const char *)sqlite3_column_text(stmt, i);
            printf("%s\t", txt ? txt : "(null)");
        }
        printf("\n");
    }

    sqlite3_finalize(stmt);
}

void aelion_dash_stats(aelion_db_t *db) {
    printf("\n\x1b[36m=== AELION STATS ===\x1b[0m\n");
    run_query(db, "SELECT COUNT(*) AS total_files FROM fs_items;");
    run_query(db, "SELECT COUNT(*) AS total_changes FROM fs_changes;");
    run_query(db, "SELECT COUNT(*) AS hud_events FROM hud_events;");
}

void aelion_dash_top_sizes(aelion_db_t *db) {
    printf("\n\x1b[36m=== TOP FILE SIZES ===\x1b[0m\n");
    run_query(db,
        "SELECT size_bytes, path "
        "FROM fs_items "
        "ORDER BY size_bytes DESC "
        "LIMIT 20;");
}

void aelion_dash_top_dupes(aelion_db_t *db) {
    printf("\n\x1b[36m=== TOP DUPLICATE GROUPS ===\x1b[0m\n");
    run_query(db,
        "SELECT hash, COUNT(*) AS cnt "
        "FROM fs_items "
        "WHERE hash <> '' "
        "GROUP BY hash "
        "HAVING cnt > 1 "
        "ORDER BY cnt DESC "
        "LIMIT 20;");
}

void aelion_dash_recent_changes(aelion_db_t *db) {
    printf("\n\x1b[36m=== RECENT CHANGES ===\x1b[0m\n");
    run_query(db,
        "SELECT ts, change_type, path "
        "FROM fs_changes "
        "ORDER BY ts DESC "
        "LIMIT 20;");
}

void aelion_dash_errors(aelion_db_t *db) {
    printf("\n\x1b[36m=== HUD ERRORS ===\x1b[0m\n");
    run_query(db,
        "SELECT ts, message "
        "FROM hud_events "
        "WHERE level = 'ERROR' "
        "ORDER BY ts DESC;");
}

void aelion_dash_events(aelion_db_t *db) {
    printf("\n\x1b[36m=== HUD EVENTS ===\x1b[0m\n");
    run_query(db,
        "SELECT ts, level, message "
        "FROM hud_events "
        "ORDER BY ts DESC "
        "LIMIT 50;");
}

void aelion_dash_query(aelion_db_t *db, const char *sql) {
    printf("\n\x1b[36m=== CUSTOM QUERY ===\x1b[0m\n");
    run_query(db, sql);
}
