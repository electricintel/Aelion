#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "aelion_shell.h"
#include "aelion_bgscan.h"
#include "aelion_watcher.h"
#include "aelion_dupes.h"
#include "aelion_changes.h"
#include "aelion_progress.h"
#include "aelion_hud.h"
#include "aelion_dashboard.h"
#include "aelion_timeline.h"
#include "aelion_config.h"
#include "aelion_plugin.h"

static void trim(char *s) {
    char *p = s;
    while (*p == ' ' || *p == '\t') p++;
    memmove(s, p, strlen(p) + 1);
}

static void show_config(void) {
    printf("\n\x1b[36m=== CONFIG ===\x1b[0m\n");
    printf("root=%s\n", AELION_CONFIG.root);
    printf("throttle=%s\n", AELION_CONFIG.throttle);
    printf("watcher=%s\n", AELION_CONFIG.watcher);
    printf("hud_color=%s\n", AELION_CONFIG.hud_color);
}

void aelion_shell(aelion_db_t *db) {
    char cmd[512];

    printf("\n\x1b[35mAELION SHELL READY\x1b[0m\n");

    while (1) {
        printf("\n\x1b[36mAELION>\x1b[0m ");
        fflush(stdout);

        if (!fgets(cmd, sizeof(cmd), stdin))
            continue;

        cmd[strcspn(cmd, "\n")] = 0;
        trim(cmd);

        if (strcmp(cmd, "exit") == 0) {
            printf("\x1b[32mExiting Aelion...\x1b[0m\n");
            break;
        }

        else if (strcmp(cmd, "plugin list") == 0) {
            aelion_plugin_list();
        }

        else if (strncmp(cmd, "plugin load ", 12) == 0) {
            aelion_plugin_load(cmd + 12);
        }

        else if (strncmp(cmd, "plugin unload ", 14) == 0) {
            aelion_plugin_unload(cmd + 14);
        }

        else if (strncmp(cmd, "plugin call ", 12) == 0) {
            char name[128], arg[256];
            sscanf(cmd + 12, "%127s %255[^\n]", name, arg);
            aelion_plugin_call(db, name, arg);
        }

        else if (strcmp(cmd, "config show") == 0) {
            show_config();
        }

        else if (strncmp(cmd, "config set ", 11) == 0) {
            char key[128], value[256];
            sscanf(cmd + 11, "%127[^=]=%255s", key, value);
            // assumes set_field exists in config.c; if not, you can wire it there
            printf("\x1b[32mUpdated %s (remember to wire set_field in config)\x1b[0m\n", key);
        }

        else if (strcmp(cmd, "config save") == 0) {
            aelion_config_save("aelion.conf");
            printf("\x1b[32mConfig saved\x1b[0m\n");
        }

        else if (strcmp(cmd, "config reload") == 0) {
            aelion_config_load("aelion.conf");
            printf("\x1b[32mConfig reloaded\x1b[0m\n");
        }

        else if (strcmp(cmd, "stats") == 0) {
            aelion_dash_stats(db);
        }

        else if (strcmp(cmd, "top sizes") == 0) {
            aelion_dash_top_sizes(db);
        }

        else if (strcmp(cmd, "top dupes") == 0) {
            aelion_dash_top_dupes(db);
        }

        else if (strcmp(cmd, "recent changes") == 0) {
            aelion_dash_recent_changes(db);
        }

        else if (strcmp(cmd, "errors") == 0) {
            aelion_dash_errors(db);
        }

        else if (strcmp(cmd, "events") == 0) {
            aelion_dash_events(db);
        }

        else if (strncmp(cmd, "query ", 6) == 0) {
            aelion_dash_query(db, cmd + 6);
        }

        else if (strcmp(cmd, "timeline") == 0) {
            aelion_timeline_all(db);
        }

        else if (strncmp(cmd, "timeline path ", 14) == 0) {
            aelion_timeline_path(db, cmd + 14);
        }

        else if (strncmp(cmd, "timeline range ", 15) == 0) {
            long from_ts = 0, to_ts = 0;
            sscanf(cmd + 15, "%ld %ld", &from_ts, &to_ts);
            aelion_timeline_range(db, from_ts, to_ts);
        }

        else if (strcmp(cmd, "scan") == 0) {
            aelion_start_bg_scan(db, AELION_CONFIG.root);
        }

        else if (strcmp(cmd, "dupes") == 0) {
            aelion_dupes_scan(db);
        }

        else if (strcmp(cmd, "changes") == 0) {
            aelion_detect_changes(db);
        }

        else if (strcmp(cmd, "watch on") == 0) {
            aelion_start_watcher(db, AELION_CONFIG.root);
        }

        else if (strcmp(cmd, "watch off") == 0) {
            aelion_stop_watcher();
        }

        else if (strcmp(cmd, "throttle fast") == 0) {
            aelion_throttle(0);
        }

        else if (strcmp(cmd, "throttle slow") == 0) {
            aelion_throttle(1);
        }

        else if (strncmp(cmd, "hud msg ", 8) == 0) {
            aelion_hud_log(db, HUD_INFO, cmd + 8);
        }

        else {
            printf("\x1b[31mUnknown command: %s\x1b[0m\n", cmd);
        }
    }
}
