CREATE TABLE IF NOT EXISTS acct (
    id INT NOT NULL AUTO_INCREMENT,
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
