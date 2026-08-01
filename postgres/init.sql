CREATE TABLE IF NOT EXISTS customers
(
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    email       VARCHAR(150),
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


INSERT INTO customers(name,email)
VALUES
('John Smith','john@example.com'),
('Alice Brown','alice@example.com');


CREATE PUBLICATION dbz_publication
FOR TABLE customers;