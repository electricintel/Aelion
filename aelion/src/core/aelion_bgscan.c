#include <windows.h>
#include <stdio.h>
#include "aelion_bgscan.h"
#include "aelion_fs_scan.h"
#include "aelion_hud.h"

typedef struct {
    aelion_db_t *db;
    const char *root;
} bg_scan_ctx_t;

static HANDLE g_scanThread = NULL;

static DWORD WINAPI bg_scan_thread(LPVOID param) {
    bg_scan_ctx_t *ctx = (bg_scan_ctx_t *)param;

    aelion_hud_log(ctx->db, HUD_INFO, "Background scan started");
    aelion_fs_scan(ctx->db, ctx->root);
    aelion_hud_log(ctx->db, HUD_INFO, "Background scan finished");

    return 0;
}

int aelion_start_bg_scan(aelion_db_t *db, const char *root) {
    if (g_scanThread != NULL) {
        printf("[BGSCAN] Scan already running\n");
        return 1;
    }

    bg_scan_ctx_t *ctx = (bg_scan_ctx_t *)malloc(sizeof(bg_scan_ctx_t));
    if (!ctx) return 1;

    ctx->db = db;
    ctx->root = root;

    g_scanThread = CreateThread(
        NULL,
        0,
        bg_scan_thread,
        ctx,
        0,
        NULL
    );

    if (g_scanThread == NULL) {
        free(ctx);
        printf("[BGSCAN] Failed to create thread\n");
        return 1;
    }

    printf("[BGSCAN] Thread started\n");
    return 0;
}

int aelion_wait_bg_scan(void) {
    if (g_scanThread == NULL)
        return 0;

    WaitForSingleObject(g_scanThread, INFINITE);
    CloseHandle(g_scanThread);
    g_scanThread = NULL;

    printf("[BGSCAN] Thread joined\n");
    return 0;
}
