#include <windows.h>
#include <stdio.h>
#include <time.h>
#include "aelion_fs_scan.h"
#include "aelion_db.h"
#include "aelion_hash.h"
#include "aelion_progress.h"
#include "aelion_hud.h"
#include "aelion_hud_overlay.h"

static long count_files(const char *root) {
    WIN32_FIND_DATAA fd;
    char searchPath[MAX_PATH];
    long count = 0;

    snprintf(searchPath, MAX_PATH, "%s\\*", root);

    HANDLE hFind = FindFirstFileA(searchPath, &fd);
    if (hFind == INVALID_HANDLE_VALUE)
        return 0;

    do {
        if (strcmp(fd.cFileName, ".") == 0 || strcmp(fd.cFileName, "..") == 0)
            continue;

        char fullPath[MAX_PATH];
        snprintf(fullPath, MAX_PATH, "%s\\%s", root, fd.cFileName);

        if (fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
            count += count_files(fullPath);
        } else {
            count++;
        }

    } while (FindNextFileA(hFind, &fd));

    FindClose(hFind);
    return count;
}

static void insert_file_record(aelion_db_t *db, const char *path, long long size, long long mtime) {
    sqlite3_stmt *stmt = NULL;

    const char *sql =
        "INSERT INTO fs_items (path, size_bytes, mtime, hash, scanned_at) "
        "VALUES (?, ?, ?, ?, ?);";

    if (aelion_db_prepare(db, sql, &stmt) != SQLITE_OK)
        return;

    char hashHex[65] = {0};
    aelion_hash_file(path, hashHex);

    sqlite3_bind_text(stmt, 1, path, -1, SQLITE_TRANSIENT);
    sqlite3_bind_int64(stmt, 2, size);
    sqlite3_bind_int64(stmt, 3, mtime);
    sqlite3_bind_text(stmt, 4, hashHex, -1, SQLITE_TRANSIENT);
    sqlite3_bind_int64(stmt, 5, (sqlite3_int64)time(NULL));

    sqlite3_step(stmt);
    sqlite3_finalize(stmt);
}

static void scan_dir(aelion_db_t *db, const char *root, long *counter, long total) {
    WIN32_FIND_DATAA fd;
    char searchPath[MAX_PATH];

    snprintf(searchPath, MAX_PATH, "%s\\*", root);

    HANDLE hFind = FindFirstFileA(searchPath, &fd);
    if (hFind == INVALID_HANDLE_VALUE)
        return;

    do {
        if (strcmp(fd.cFileName, ".") == 0 || strcmp(fd.cFileName, "..") == 0)
            continue;

        char fullPath[MAX_PATH];
        snprintf(fullPath, MAX_PATH, "%s\\%s", root, fd.cFileName);

        if (fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
            scan_dir(db, fullPath, counter, total);
        } else {
            long long size = ((long long)fd.nFileSizeHigh << 32) | fd.nFileSizeLow;

            FILETIME ft = fd.ftLastWriteTime;
            ULARGE_INTEGER ull;
            ull.LowPart = ft.dwLowDateTime;
            ull.HighPart = ft.dwHighDateTime;

            long long mtime = (long long)((ull.QuadPart - 116444736000000000ULL) / 10000000ULL);

            insert_file_record(db, fullPath, size, mtime);

            (*counter)++;
            aelion_progress_update(*counter);
            hud_overlay_set("SCANNING", *counter, total);
        }

    } while (FindNextFileA(hFind, &fd));

    FindClose(hFind);
}

int aelion_fs_scan(aelion_db_t *db, const char *root) {
    aelion_hud_log(db, HUD_INFO, "Counting files...");
    long total = count_files(root);

    aelion_progress_init(total);
    hud_overlay_set("SCANNING", 0, total);

    long counter = 0;
    scan_dir(db, root, &counter, total);

    aelion_progress_finish();
    hud_overlay_message("Scan complete");
    hud_overlay_clear();

    return 0;
}
