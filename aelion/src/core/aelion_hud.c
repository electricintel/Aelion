#include <stdio.h>
#include <time.h>
#include "aelion_hud.h"
#include "aelion_db.h"

static const char* hud_color(hud_level_t level) {
    switch (level) {
        case HUD_INFO:  return "\x1b[32m"; // green
        case HUD_WARN:  return "\x1b[33m"; // yellow
        case HUD_ERROR: return "\x1b[31m"; // red
        default:        return "\x1b[37m"; // white
    }
}

static const char* hud_level_to_str(hud_level_t level) {
    switch (level) {
        case HUD_INFO:  return "INFO";
        case HUD_WARN:  return "WARN";
        case HUD_ERROR: return "ERROR";
        default:        return "UNKNOWN";
    }
}

int aelion_hud_log(aelion_db_t *db, hud_level_t level, const char *message) {
    sqlite3_stmt *stmt = NULL;

    const char *sql =
        "INSERT INTO hud_events (ts, level, message) "
        "VALUES (?, ?, ?);";

    if (aelion_db_prepare(db, sql, &stmt) != SQLITE_OK)
        return 1;

    sqlite3_bind_int64(stmt, 1, (sqlite3_int64)time(NULL));
    sqlite3_bind_text(stmt, 2, hud_level_to_str(level), -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 3, message, -1, SQLITE_TRANSIENT);

    sqlite3_step(stmt);
    sqlite3_finalize(stmt);

    printf("%s[HUD][%s] %s\x1b[0m\n",
           hud_color(level),
           hud_level_to_str(level),
           message);

    return 0;
}
