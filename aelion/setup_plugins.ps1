# setup_plugins.ps1
# Run from Aelion project root

New-Item -ItemType Directory -Force -Path ".\plugins" | Out-Null
New-Item -ItemType Directory -Force -Path ".\include" | Out-Null
New-Item -ItemType Directory -Force -Path ".\src\core" | Out-Null

# 1. aelion_plugin.h
Set-Content -LiteralPath ".\include\aelion_plugin.h" -Value @'
#ifndef AELION_PLUGIN_H
#define AELION_PLUGIN_H

#include <windows.h>
#include "aelion_db.h"

typedef struct {
    char name[128];
    char path[256];
    HMODULE handle;
    void (*entry)(aelion_db_t *db, const char *cmd);
} aelion_plugin_t;

int aelion_plugin_load(const char *name);
int aelion_plugin_unload(const char *name);
void aelion_plugin_list(void);
int aelion_plugin_call(aelion_db_t *db, const char *name, const char *cmd);

#endif
'@

# 2. aelion_plugin.c
Set-Content -LiteralPath ".\src\core\aelion_plugin.c" -Value @'
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <windows.h>
#include "aelion_plugin.h"
#include "aelion_hud.h"

#define MAX_PLUGINS 64
static aelion_plugin_t plugins[MAX_PLUGINS];
static int plugin_count = 0;

static aelion_plugin_t* find_plugin(const char *name) {
    for (int i = 0; i < plugin_count; i++)
        if (strcmp(plugins[i].name, name) == 0)
            return &plugins[i];
    return NULL;
}

int aelion_plugin_load(const char *name) {
    if (find_plugin(name)) {
        printf("\x1b[33m[PLUGIN] Already loaded: %s\x1b[0m\n", name);
        return 1;
    }

    char dllPath[256];
    snprintf(dllPath, sizeof(dllPath), "plugins/%s.dll", name);

    HMODULE h = LoadLibraryA(dllPath);
    if (!h) {
        printf("\x1b[31m[PLUGIN] Failed to load %s\x1b[0m\n", dllPath);
        return 1;
    }

    void (*entry)(aelion_db_t*, const char*) =
        (void (*)(aelion_db_t*, const char*))GetProcAddress(h, "aelion_plugin_entry");

    if (!entry) {
        printf("\x1b[31m[PLUGIN] Missing entry() in %s\x1b[0m\n", dllPath);
        FreeLibrary(h);
        return 1;
    }

    aelion_plugin_t *p = &plugins[plugin_count++];
    strncpy(p->name, name, sizeof(p->name)-1);
    strncpy(p->path, dllPath, sizeof(p->path)-1);
    p->handle = h;
    p->entry = entry;

    printf("\x1b[32m[PLUGIN] Loaded: %s\x1b[0m\n", name);
    return 0;
}

int aelion_plugin_unload(const char *name) {
    aelion_plugin_t *p = find_plugin(name);
    if (!p) {
        printf("\x1b[31m[PLUGIN] Not loaded: %s\x1b[0m\n", name);
        return 1;
    }

    FreeLibrary(p->handle);

    for (int i = 0; i < plugin_count; i++) {
        if (&plugins[i] == p) {
            plugins[i] = plugins[plugin_count - 1];
            plugin_count--;
            break;
        }
    }

    printf("\x1b[32m[PLUGIN] Unloaded: %s\x1b[0m\n", name);
    return 0;
}

void aelion_plugin_list(void) {
    printf("\n\x1b[36m=== LOADED PLUGINS ===\x1b[0m\n");
    for (int i = 0; i < plugin_count; i++)
        printf("%s\t%s\n", plugins[i].name, plugins[i].path);
}

int aelion_plugin_call(aelion_db_t *db, const char *name, const char *cmd) {
    aelion_plugin_t *p = find_plugin(name);
    if (!p) {
        printf("\x1b[31m[PLUGIN] Not loaded: %s\x1b[0m\n", name);
        return 1;
    }

    p->entry(db, cmd);
    return 0;
}
'@

# 3. Update shell to add plugin commands (overwrite for now)
Set-Content -LiteralPath ".\src\core\aelion_shell.c" -Value @'
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
'@

# 4. Update Makefile to include plugin module
Set-Content -LiteralPath ".\Makefile" -Value @'
CC = gcc
CFLAGS = -Wall -Wextra -Iinclude
LDFLAGS = -LC:\sqlite -ladvapi32
LIBS = -lsqlite3

SRC = src/core/aelion_main.c \
      src/core/aelion_shell.c \
      src/core/aelion_dashboard.c \
      src/core/aelion_timeline.c \
      src/core/aelion_config.c \
      src/core/aelion_fs_scan.c \
      src/core/aelion_hud.c \
      src/core/aelion_hud_anim.c \
      src/core/aelion_hud_overlay.c \
      src/core/aelion_hash.c \
      src/core/aelion_progress.c \
      src/core/aelion_dupes.c \
      src/core/aelion_changes.c \
      src/core/aelion_bgscan.c \
      src/core/aelion_watcher.c \
      src/core/aelion_plugin.c \
      src/db/aelion_db.c

all: aelion

aelion: $(SRC)
    $(CC) $(CFLAGS) -o aelion $(SRC) $(LDFLAGS) $(LIBS)

clean:
    rm -f aelion
'@

# 5. Example plugin source (you compile this as a DLL separately)
Set-Content -LiteralPath ".\plugins\hello.c" -Value @'
#include <stdio.h>
#include "aelion_db.h"

__declspec(dllexport)
void aelion_plugin_entry(aelion_db_t *db, const char *cmd) {
    printf("\x1b[35m[HELLO PLUGIN] Command: %s\x1b[0m\n", cmd);
}
'

Write-Host "Plugin system scaffolding created. Build aelion, then: plugin load hello; plugin call hello test123"
# ============================
# AELION PLUGIN SYSTEM SETUP
# ============================

Write-Host "Creating plugin system..."

# --- Ensure folders exist ---
New-Item -ItemType Directory -Force -Path ".\plugins" | Out-Null
New-Item -ItemType Directory -Force -Path ".\include" | Out-Null
New-Item -ItemType Directory -Force -Path ".\src\core" | Out-Null

# --- aelion_plugin.h ---
Set-Content -LiteralPath ".\include\aelion_plugin.h" -Value @'
#ifndef AELION_PLUGIN_H
#define AELION_PLUGIN_H

#include <windows.h>
#include "aelion_db.h"

typedef struct {
    char name[128];
    char path[256];
    HMODULE handle;
    void (*entry)(aelion_db_t *db, const char *cmd);
} aelion_plugin_t;

int aelion_plugin_load(const char *name);
int aelion_plugin_unload(const char *name);
void aelion_plugin_list(void);
int aelion_plugin_call(aelion_db_t *db, const char *name, const char *cmd);

#endif
'@

# --- aelion_plugin.c ---
Set-Content -LiteralPath ".\src\core\aelion_plugin.c" -Value @'
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <windows.h>
#include "aelion_plugin.h"
#include "aelion_hud.h"

#define MAX_PLUGINS 64
static aelion_plugin_t plugins[MAX_PLUGINS];
static int plugin_count = 0;

static aelion_plugin_t* find_plugin(const char *name) {
    for (int i = 0; i < plugin_count; i++)
        if (strcmp(plugins[i].name, name) == 0)
            return &plugins[i];
    return NULL;
}

int aelion_plugin_load(const char *name) {
    if (find_plugin(name)) {
        printf("\x1b[33m[PLUGIN] Already loaded: %s\x1b[0m\n", name);
        return 1;
    }

    char dllPath[256];
    snprintf(dllPath, sizeof(dllPath), "plugins/%s.dll", name);

    HMODULE h = LoadLibraryA(dllPath);
    if (!h) {
        printf("\x1b[31m[PLUGIN] Failed to load %s\x1b[0m\n", dllPath);
        return 1;
    }

    void (*entry)(aelion_db_t*, const char*) =
        (void (*)(aelion_db_t*, const char*))GetProcAddress(h, "aelion_plugin_entry");

    if (!entry) {
        printf("\x1b[31m[PLUGIN] Missing entry() in %s\x1b[0m\n", dllPath);
        FreeLibrary(h);
        return 1;
    }

    aelion_plugin_t *p = &plugins[plugin_count++];
    strncpy(p->name, name, sizeof(p->name)-1);
    strncpy(p->path, dllPath, sizeof(p->path)-1);
    p->handle = h;
    p->entry = entry;

    printf("\x1b[32m[PLUGIN] Loaded: %s\x1b[0m\n", name);
    return 0;
}

int aelion_plugin_unload(const char *name) {
    aelion_plugin_t *p = find_plugin(name);
    if (!p) {
        printf("\x1b[31m[PLUGIN] Not loaded: %s\x1b[0m\n", name);
        return 1;
    }

    FreeLibrary(p->handle);

    for (int i = 0; i < plugin_count; i++) {
        if (&plugins[i] == p) {
            plugins[i] = plugins[plugin_count - 1];
            plugin_count--;
            break;
        }
    }

    printf("\x1b[32m[PLUGIN] Unloaded: %s\x1b[0m\n", name);
    return 0;
}

void aelion_plugin_list(void) {
    printf("\n\x1b[36m=== LOADED PLUGINS ===\x1b[0m\n");
    for (int i = 0; i < plugin_count; i++)
        printf("%s\t%s\n", plugins[i].name, plugins[i].path);
}

int aelion_plugin_call(aelion_db_t *db, const char *name, const char *cmd) {
    aelion_plugin_t *p = find_plugin(name);
    if (!p) {
        printf("\x1b[31m[PLUGIN] Not loaded: %s\x1b[0m\n", name);
        return 1;
    }

    p->entry(db, cmd);
    return 0;
}
'@

# --- Example plugin source ---
Set-Content -LiteralPath ".\plugins\hello.c" -Value @'
#include <stdio.h>
#include "aelion_db.h"

__declspec(dllexport)
void aelion_plugin_entry(aelion_db_t *db, const char *cmd) {
    printf("\x1b[35m[HELLO PLUGIN] Command: %s\x1b[0m\n", cmd);
}
'@

# --- Update Makefile ---
Set-Content -LiteralPath ".\Makefile" -Value @'
CC = gcc
CFLAGS = -Wall -Wextra -Iinclude
LDFLAGS = -LC:\sqlite -ladvapi32
LIBS = -lsqlite3

SRC = src/core/aelion_main.c \
      src/core/aelion_shell.c \
      src/core/aelion_dashboard.c \
      src/core/aelion_timeline.c \
      src/core/aelion_config.c \
      src/core/aelion_fs_scan.c \
      src/core/aelion_hud.c \
      src/core/aelion_hud_anim.c \
      src/core/aelion_hud_overlay.c \
      src/core/aelion_hash.c \
      src/core/aelion_progress.c \
      src/core/aelion_dupes.c \
      src/core/aelion_changes.c \
      src/core/aelion_bgscan.c \
      src/core/aelion_watcher.c \
      src/core/aelion_plugin.c \
      src/db/aelion_db.c

all: aelion

aelion: $(SRC)
    $(CC) $(CFLAGS) -o aelion $(SRC) $(LDFLAGS) $(LIBS)

clean:
    rm -f aelion
'@

Write-Host "Plugin system installed successfully."
Write-Host "Compile hello.c into hello.dll, then use:"
Write-Host "  plugin load hello"
Write-Host "  plugin call hello test123"
