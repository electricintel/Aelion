CREATE TABLE IF NOT EXISTS fs_changes (
    id          INTEGER PRIMARY KEY,
    path        TEXT NOT NULL,
    change_type TEXT NOT NULL,
    old_hash    TEXT,
    new_hash    TEXT,
    ts          INTEGER NOT NULL
);
