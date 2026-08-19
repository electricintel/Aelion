#include <stdio.h>
#include "aelion_db.h"

int aelion_db_open(aelion_db_t *db) {
    int rc = sqlite3_open(AELION_DB_PATH, &db->handle);
    if (rc != SQLITE_OK) {
        fprintf(stderr, "[DB] Failed to open %s: %s\n",
                AELION_DB_PATH, sqlite3_errmsg(db->handle));
        return rc;
    }
    return SQLITE_OK;
}

void aelion_db_close(aelion_db_t *db) {
    if (db->handle) {
        sqlite3_close(db->handle);
        db->handle = NULL;
    }
}

int aelion_db_exec(aelion_db_t *db, const char *sql) {
    char *errmsg = NULL;
    int rc = sqlite3_exec(db->handle, sql, NULL, NULL, &errmsg);
    if (rc != SQLITE_OK) {
        fprintf(stderr, "[DB] exec error: %s\n", errmsg);
        sqlite3_free(errmsg);
    }
    return rc;
}

int aelion_db_prepare(aelion_db_t *db, const char *sql, sqlite3_stmt **stmt) {
    int rc = sqlite3_prepare_v2(db->handle, sql, -1, stmt, NULL);
    if (rc != SQLITE_OK) {
        fprintf(stderr, "[DB] prepare error: %s\n", sqlite3_errmsg(db->handle));
    }
    return rc;
}
