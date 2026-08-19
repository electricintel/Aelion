#ifndef AELION_DB_H
#define AELION_DB_H

#include <sqlite3.h>

#define AELION_DB_PATH "db/aelion.db"

typedef struct {
    sqlite3 *handle;
} aelion_db_t;

int aelion_db_open(aelion_db_t *db);
void aelion_db_close(aelion_db_t *db);
int aelion_db_exec(aelion_db_t *db, const char *sql);
int aelion_db_prepare(aelion_db_t *db, const char *sql, sqlite3_stmt **stmt);

#endif
