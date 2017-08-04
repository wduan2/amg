CREATE TABLE IF NOT EXISTS acct (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid TEXT NOT NULL,
    username TEXT NOT NULL,
    password TEXT NOT NULL,
    date_created DATE NOT NULL,
    date_updated DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS acct_desc (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    description TEXT,
    label TEXT NOT NULL,
    link TEXT,
    date_created DATE NOT NULL,
    date_updated DATE NOT NULL,
    acct_id INT NOT NULL,
    FOREIGN KEY (acct_id) REFERENCES acct(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS security_question (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    date_created DATE NOT NULL,
    date_updated DATE NOT NULL,
    acct_id INT NOT NULL,
    FOREIGN KEY (acct_id) REFERENCES acct(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS passcode (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sys_user TEXT UNIQUE NOT NULL,
    passcode TEXT NOT NULL
);
