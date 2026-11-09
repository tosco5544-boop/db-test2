-- テーブル作成
CREATE TABLE prefectures (
  id INTEGER PRIMARY KEY CHECK (id BETWEEN 1 AND 47),
  name TEXT NOT NULL,
  region TEXT NOT NULL,
  sort_order INTEGER NOT NULL
);

CREATE TABLE statuses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT NOT NULL UNIQUE,
  label TEXT NOT NULL,
  color TEXT NOT NULL CHECK (length(color) = 7 AND substr(color, 1, 1) = '#'),
  sort_order INTEGER NOT NULL,
  counts_as_visited INTEGER NOT NULL DEFAULT 0 CHECK (counts_as_visited IN (0, 1))
);

CREATE TABLE editors (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE prefecture_states (
  prefecture_id INTEGER PRIMARY KEY REFERENCES prefectures(id),
  status_id INTEGER NOT NULL REFERENCES statuses(id),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_by INTEGER REFERENCES editors(id)
);

CREATE TABLE state_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  prefecture_id INTEGER NOT NULL REFERENCES prefectures(id),
  from_status_id INTEGER REFERENCES statuses(id),
  to_status_id INTEGER NOT NULL REFERENCES statuses(id),
  changed_at TEXT NOT NULL DEFAULT (datetime('now')),
  changed_by INTEGER REFERENCES editors(id)
);

CREATE INDEX idx_history_pref ON state_history (prefecture_id, changed_at);
