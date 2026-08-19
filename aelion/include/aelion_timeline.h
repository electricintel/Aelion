#ifndef AELION_TIMELINE_H
#define AELION_TIMELINE_H

#include "aelion_db.h"

void aelion_timeline_all(aelion_db_t *db);
void aelion_timeline_range(aelion_db_t *db, long from_ts, long to_ts);
void aelion_timeline_path(aelion_db_t *db, const char *path);

#endif
