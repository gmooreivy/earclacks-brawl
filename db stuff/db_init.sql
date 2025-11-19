DROP DATABASE  IF EXISTS earclash;


CREATE DATABASE earclash;
USE earclash;

CREATE TABLE IF NOT EXISTS leaderboard (
    id INTEGER(25) AUTO_INCREMENT PRIMARY KEY,
    user VARCHAR(25) NOT NULL,
    score INTEGER(4) DEFAULT 0
);

CREATE TABLE IF NOT EXISTS analytics (
    id INT(50) AUTO_INCREMENT PRIMARY KEY,
    player TEXT(10) NOT NULL,
    -- Type of weapon player chose
    opponent TEXT(10) NOT NULL,
    -- Type of weapon player did not choose, and is going against
    matchLength INTEGER(25) NOT NULL,
    win BOOLEAN NOT NULL

);

INSERT INTO leaderboard (user, score) VALUES
('John Doe', 30),
('Jane Smith', 25),
('Alice Johnson', 35),
('Bob Brown', 40);

INSERT INTO analytics(player, opponent, matchLength, win) VALUES
('spear', 'sword', 158, 1),
('unarmed', 'dagger', 104, 1),
('sword', 'dagger', 195, 0),
('spear', 'unarmed', 174, 0);