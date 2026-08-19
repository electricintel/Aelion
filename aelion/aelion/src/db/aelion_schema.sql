CREATE TABLE IF NOT EXISTS fs_items (
    id          INTEGER PRIMARY KEY,
    path        TEXT NOT NULL,
    size_bytes  INTEGER,
    mtime       INTEGER,
    hash        TEXT,
    scanned_at  INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS hud_events (
    id          INTEGER PRIMARY KEY,
    ts          INTEGER NOT NULL,
    level       TEXT NOT NULL,
    message     TEXT NOT NULL
);
