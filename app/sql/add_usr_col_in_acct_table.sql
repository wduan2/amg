ALTER TABLE acct ADD COLUMN sys_user VARCHAR(255) NOT NULL DEFAULT "unkonwn";

-- Unfortunately Sqlite3 doesn't support this
-- ALTER TABLE acct ADD CONSTRAINT fk_sys_usr FOREIGN KEY (sys_usr) REFERENCES passcode(sys_user);
