CREATE TABLE IF NOT EXISTS computer_info (
    serial_number TEXT PRIMARY KEY,
    user_name TEXT NOT NULL,
    cpu_short TEXT NOT NULL,
    appearance TEXT,
    keyboard_touch TEXT,
    battery TEXT,
    boot TEXT,
    record_time DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS info_old (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    serial_number TEXT,
    -- 其他字段与computer_info相同...
    archived_time DATETIME DEFAULT CURRENT_TIMESTAMP
);