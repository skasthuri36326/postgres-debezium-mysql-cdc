CREATE TABLE IF NOT EXISTS customers
(
    id          INT PRIMARY KEY,
    name        VARCHAR(100),
    email       VARCHAR(150),
    created_at  TIMESTAMP,
    updated_at  TIMESTAMP
);