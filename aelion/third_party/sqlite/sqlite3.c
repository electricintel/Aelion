/* Minimal SQLite3 stub implementation (public domain) */
/* This is NOT full SQLite — only enough to satisfy linking for plugins. */

#include "sqlite3.h"
#include <stdio.h>

int sqlite3_open(const char *filename, sqlite3 **ppDb) {
    *ppDb = NULL;
    return SQLITE_OK;
}

int sqlite3_close(sqlite3* db) {
    return SQLITE_OK;
}

int sqlite3_prepare_v2(sqlite3* db, const char *zSql, int nByte, sqlite3_stmt **ppStmt, const char **pzTail) {
    *ppStmt = NULL;
    return SQLITE_OK;
}

int sqlite3_step(sqlite3_stmt* stmt) {
    return SQLITE_DONE;
}

int sqlite3_finalize(sqlite3_stmt* stmt) {
    return SQLITE_OK;
}

const unsigned char *sqlite3_column_text(sqlite3_stmt* stmt, int iCol) {
    return (const unsigned char*)"";
}

sqlite3_int64 sqlite3_column_int64(sqlite3_stmt* stmt, int iCol) {
    return 0;
}
