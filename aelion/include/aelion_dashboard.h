#ifndef AELION_DASHBOARD_H
#define AELION_DASHBOARD_H

#include "aelion_db.h"

void aelion_dash_stats(aelion_db_t *db);
void aelion_dash_top_sizes(aelion_db_t *db);
void aelion_dash_top_dupes(aelion_db_t *db);
void aelion_dash_recent_changes(aelion_db_t *db);
void aelion_dash_errors(aelion_db_t *db);
void aelion_dash_events(aelion_db_t *db);
void aelion_dash_query(aelion_db_t *db, const char *sql);

#endif
