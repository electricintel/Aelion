#ifndef AELION_BGSCAN_H
#define AELION_BGSCAN_H

#include "aelion_db.h"

int aelion_start_bg_scan(aelion_db_t *db, const char *root);
int aelion_wait_bg_scan(void);

#endif
