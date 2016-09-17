CREATE TABLE IF NOT EXISTS acct (
    id INT NOT NULL AUTO_INCREMENT,
    uuid varchar(255) NOT NULL,
    username varchar(255) NOT NULL,
    password varchar(255) NOT NULL,
    date_created DATE NOT NULL,
    date_updated DATE NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS acct_desc (
    id INT NOT NULL AUTO_INCREMENT,
    description VARCHAR(255),
    label VARCHAR(30) NOT NULL,
    link VARCHAR(255),
    date_created DATE NOT NULL,
    date_updated DATE NOT NULL,
    acct_id INT NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (acct_id) REFERENCES acct(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS security_question (
    id INT NOT NULL AUTO_INCREMENT,
    question VARCHAR(255) NOT NULL,
    answer VARCHAR(255) NOT NULL,
    date_created DATE NOT NULL,
    date_updated DATE NOT NULL,
    acct_id INT NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (acct_id) REFERENCES acct(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS passcode (
    sys_user VARCHAR(255) NOT NULL,
    passcode VARCHAR(4) NOT NULL,
    PRIMARY KEY (sys_user)
);
