#ifndef AELION_PROGRESS_H
#define AELION_PROGRESS_H

void aelion_progress_init(long total);
void aelion_progress_update(long current);
void aelion_progress_finish(void);

void aelion_throttle(int mode); // 0 = fast, 1 = slow

#endif
