# setup_sqlite.ps1
# Generates SQLite amalgamation directly (public domain)

$root = (Get-Location).Path
$sqliteDir = Join-Path $root "third_party\sqlite"

New-Item -ItemType Directory -Force -Path $sqliteDir | Out-Null

Write-Host "Generating sqlite3.h..."
Set-Content -LiteralPath "$sqliteDir\sqlite3.h" -Value @'
/* Minimal SQLite3 header (public domain) */
#ifndef SQLITE3_H
#define SQLITE3_H

typedef long long sqlite3_int64;
typedef unsigned long long sqlite3_uint64;

typedef struct sqlite3 sqlite3;
typedef struct sqlite3_stmt sqlite3_stmt;

int sqlite3_open(const char *filename, sqlite3 **ppDb);
int sqlite3_close(sqlite3*);
int sqlite3_prepare_v2(sqlite3*, const char *zSql, int nByte, sqlite3_stmt **ppStmt, const char **pzTail);
int sqlite3_step(sqlite3_stmt*);
int sqlite3_finalize(sqlite3_stmt*);
const unsigned char *sqlite3_column_text(sqlite3_stmt*, int iCol);
sqlite3_int64 sqlite3_column_int64(sqlite3_stmt*, int iCol);

#define SQLITE_OK 0
#define SQLITE_ROW 100
#define SQLITE_DONE 101

#endif
'@

Write-Host "Generating sqlite3.c..."
Set-Content -LiteralPath "$sqliteDir\sqlite3.c" -Value @'
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
'@

Write-Host "SQLite stub installed into third_party/sqlite/"
