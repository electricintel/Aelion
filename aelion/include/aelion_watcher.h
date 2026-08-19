#ifndef AELION_WATCHER_H
#define AELION_WATCHER_H

#include "aelion_db.h"

int aelion_start_watcher(aelion_db_t *db, const char *root);
int aelion_stop_watcher(void);

#endif
