#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "aelion_watcher.h"
#include "aelion_hud.h"
#include "aelion_db.h"

static HANDLE g_watchThread = NULL;
static HANDLE g_stopEvent = NULL;

typedef struct {
    aelion_db_t *db;
    const char *root;
} watcher_ctx_t;

static void log_change(aelion_db_t *db, const char *path, const char *type) {
    sqlite3_stmt *stmt = NULL;

    const char *sql =
        "INSERT INTO fs_changes (path, change_type, old_hash, new_hash, ts) "
        "VALUES (?, ?, '', '', ?);";

    if (aelion_db_prepare(db, sql, &stmt) != SQLITE_OK)
        return;

    sqlite3_bind_text(stmt, 1, path, -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 2, type, -1, SQLITE_TRANSIENT);
    sqlite3_bind_int64(stmt, 3, (sqlite3_int64)time(NULL));

    sqlite3_step(stmt);
    sqlite3_finalize(stmt);

    char msg[256];
    snprintf(msg, sizeof(msg), "[WATCH] %s: %s", type, path);
    aelion_hud_log(db, HUD_WARN, msg);
}

static DWORD WINAPI watcher_thread(LPVOID param) {
    watcher_ctx_t *ctx = (watcher_ctx_t *)param;

    wchar_t wpath[MAX_PATH];
    MultiByteToWideChar(CP_UTF8, 0, ctx->root, -1, wpath, MAX_PATH);

    HANDLE hDir = CreateFileW(
        wpath,
        FILE_LIST_DIRECTORY,
        FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE,
        NULL,
        OPEN_EXISTING,
        FILE_FLAG_BACKUP_SEMANTICS,
        NULL
    );

    if (hDir == INVALID_HANDLE_VALUE) {
        aelion_hud_log(ctx->db, HUD_ERROR, "Watcher failed to open directory");
        return 0;
    }

    aelion_hud_log(ctx->db, HUD_INFO, "Real-time watcher started");

    BYTE buffer[4096];
    DWORD bytesReturned;

    while (1) {
        if (WaitForSingleObject(g_stopEvent, 0) == WAIT_OBJECT_0)
            break;

        if (!ReadDirectoryChangesW(
                hDir,
                &buffer,
                sizeof(buffer),
                TRUE,
                FILE_NOTIFY_CHANGE_FILE_NAME |
                FILE_NOTIFY_CHANGE_DIR_NAME |
                FILE_NOTIFY_CHANGE_LAST_WRITE |
                FILE_NOTIFY_CHANGE_SIZE,
                &bytesReturned,
                NULL,
                NULL)) {
            continue;
        }

        FILE_NOTIFY_INFORMATION *fni = (FILE_NOTIFY_INFORMATION *)buffer;

        char filename[MAX_PATH];
        int len = WideCharToMultiByte(CP_UTF8, 0, fni->FileName, fni->FileNameLength / 2,
                                      filename, MAX_PATH, NULL, NULL);
        filename[len] = 0;

        switch (fni->Action) {
        case FILE_ACTION_ADDED:
            log_change(ctx->db, filename, "REALTIME_NEW");
            break;
        case FILE_ACTION_REMOVED:
            log_change(ctx->db, filename, "REALTIME_DELETED");
            break;
        case FILE_ACTION_MODIFIED:
            log_change(ctx->db, filename, "REALTIME_MODIFIED");
            break;
        case FILE_ACTION_RENAMED_OLD_NAME:
            log_change(ctx->db, filename, "REALTIME_RENAME_OLD");
            break;
        case FILE_ACTION_RENAMED_NEW_NAME:
            log_change(ctx->db, filename, "REALTIME_RENAME_NEW");
            break;
        }
    }

    CloseHandle(hDir);
    aelion_hud_log(ctx->db, HUD_INFO, "Real-time watcher stopped");
    return 0;
}

int aelion_start_watcher(aelion_db_t *db, const char *root) {
    if (g_watchThread != NULL)
        return 1;

    g_stopEvent = CreateEvent(NULL, TRUE, FALSE, NULL);

    watcher_ctx_t *ctx = malloc(sizeof(watcher_ctx_t));
    ctx->db = db;
    ctx->root = root;

    g_watchThread = CreateThread(NULL, 0, watcher_thread, ctx, 0, NULL);

    return g_watchThread ? 0 : 1;
}

int aelion_stop_watcher(void) {
    if (g_watchThread == NULL)
        return 0;

    SetEvent(g_stopEvent);
    WaitForSingleObject(g_watchThread, INFINITE);

    CloseHandle(g_watchThread);
    CloseHandle(g_stopEvent);

    g_watchThread = NULL;
    g_stopEvent = NULL;

    return 0;
}
