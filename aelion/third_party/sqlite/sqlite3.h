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
