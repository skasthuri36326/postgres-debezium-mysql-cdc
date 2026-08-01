# PostgreSQL → Debezium → Kafka KRaft → MySQL CDC

A complete Change Data Capture (CDC) pipeline using:

- PostgreSQL 16
- Debezium
- Apache Kafka 3.9 (KRaft mode)
- Kafka Connect
- Debezium JDBC Sink Connector
- MySQL 8.4

This project demonstrates capturing PostgreSQL database changes using WAL logical replication and synchronizing changes into MySQL using Debezium and Kafka.

---

# Architecture

```
PostgreSQL
    |
    | WAL Logical Replication
    |
    v
Debezium PostgreSQL Source Connector
    |
    |
    v
Kafka (KRaft Mode)
(No ZooKeeper)
    |
    |
    v
Debezium JDBC Sink Connector
    |
    |
    v
MySQL
```

---

# Features

- No ZooKeeper
- Kafka KRaft mode
- PostgreSQL WAL replication
- Debezium CDC
- Kafka Connect integration
- MySQL synchronization
- Docker Compose deployment

---

# Project Structure

```
postgres-debezium-mysql-cdc/

├── README.md
├── docker-compose.yml
├── .env.example
├── .gitignore

├── kafka-connect/
│   └── Dockerfile

├── postgres/
│   └── init.sql

├── mysql/
│   └── init.sql

├── connectors/
│   ├── postgres-source.json
│   └── mysql-sink.json

└── scripts/
    ├── register-source.sh
    ├── register-sink.sh
    ├── status.sh
    └── test.sh
```

---

# Requirements

Install:

- Docker
- Docker Compose

Verify:

```bash
docker --version

docker compose version
```

---

# Environment Configuration

Create the local environment file:

```bash
cp .env.example .env
```

Example `.env.example`:

```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=inventory

MYSQL_ROOT_PASSWORD=root
MYSQL_DATABASE=inventory
```

The `.env` file contains local configuration values and should not be committed to Git.

---

# Start CDC Environment

## Build containers

```bash
docker compose build
```

## Start services

```bash
docker compose up -d
```

Check running containers:

```bash
docker ps
```

Expected containers:

```
cdc-postgres
cdc-mysql
cdc-kafka
cdc-connect
```

---

# Services and Ports

| Service | Port |
|---|---:|
| PostgreSQL | 5432 |
| MySQL | 3306 |
| Kafka | 9092 |
| Kafka Connect REST API | 8083 |

---

# Make Scripts Executable

Before running connector scripts:

```bash
chmod +x scripts/*.sh
```

Verify:

```bash
ls -l scripts/
```

Expected:

```
-rwxr-xr-x register-source.sh
-rwxr-xr-x register-sink.sh
-rwxr-xr-x status.sh
-rwxr-xr-x test.sh
```

---

# Register Debezium PostgreSQL Source Connector

Run:

```bash
./scripts/register-source.sh
```

Creates:

```
postgres-source
```

connector.

---

# Register Debezium MySQL Sink Connector

Run:

```bash
./scripts/register-sink.sh
```

Creates:

```
mysql-sink
```

connector.

---

# Check Connector Status

Check Debezium connector status:

```bash
./scripts/status.sh
```

Expected connector state:

```
RUNNING
```

---

## Manual Status Check

PostgreSQL Source:

```bash
curl \
http://localhost:8083/connectors/postgres-source/status
```

MySQL Sink:

```bash
curl \
http://localhost:8083/connectors/mysql-sink/status
```

Both connectors should show:

```
RUNNING
```

---

# Test CDC Replication

Run:

```bash
./scripts/test.sh
```

The test performs:

1. Insert data into PostgreSQL
2. Debezium captures WAL changes
3. Kafka receives CDC events
4. MySQL receives synchronized data

The pipeline validates:

- INSERT events
- UPDATE events
- DELETE events

---

# Manual CDC Test

## Connect to PostgreSQL

```bash
docker exec -it cdc-postgres \
psql -U postgres -d inventory
```

Insert data:

```sql
INSERT INTO customers(name,email)
VALUES
('CDC User','cdc@test.com');
```

Update data:

```sql
UPDATE customers
SET name='CDC Updated'
WHERE email='cdc@test.com';
```

Delete data:

```sql
DELETE FROM customers
WHERE email='cdc@test.com';
```

---

# Verify Data in MySQL

Connect:

```bash
docker exec -it cdc-mysql \
mysql -uroot -proot inventory
```

Query:

```sql
SELECT * FROM customers;
```

The PostgreSQL changes should appear in MySQL.

---

# PostgreSQL CDC Configuration

PostgreSQL logical replication is enabled using:

```yaml
wal_level=logical
```

Configured in:

```
docker-compose.yml
```

Verify:

```bash
docker exec -it cdc-postgres \
psql -U postgres \
-c "SHOW wal_level;"
```

Expected:

```
logical
```

---

# Kafka Configuration

This project uses Kafka KRaft mode.

ZooKeeper is not required.

Kafka runs with:

```
Broker
+
Controller
```

using the built-in Raft metadata management.

---

# Kafka Topics

List Kafka topics:

```bash
docker exec -it cdc-kafka \
kafka-topics.sh \
--bootstrap-server localhost:9092 \
--list
```

Debezium creates topics similar to:

```
postgres.public.customers
```

---

# Useful Docker Commands

## View logs

Kafka Connect:

```bash
docker logs cdc-connect
```

PostgreSQL:

```bash
docker logs cdc-postgres
```

MySQL:

```bash
docker logs cdc-mysql
```

---

## Stop environment

```bash
docker compose down
```

Remove volumes:

```bash
docker compose down -v
```

---

# Troubleshooting

## Connector already exists

Delete the connector:

```bash
curl -X DELETE \
http://localhost:8083/connectors/postgres-source
```

or:

```bash
curl -X DELETE \
http://localhost:8083/connectors/mysql-sink
```

Then register again.

---

## PostgreSQL WAL Error

Check:

```bash
docker exec -it cdc-postgres \
psql -U postgres \
-c "SHOW wal_level;"
```

Expected:

```
logical
```

---

## Kafka Connect Issues

Check logs:

```bash
docker logs cdc-connect
```

Common causes:

- Kafka is not ready
- Connector plugin is missing
- Database connection failed

---

# Production Improvements

For production deployments consider:

- Multiple Kafka brokers
- TLS encryption
- Authentication
- Schema Registry
- Secrets management
- Monitoring
- Backup strategy
- Kubernetes deployment
- Dead Letter Queue handling

---

# Summary

This project demonstrates:

```
PostgreSQL
      |
      v
Debezium CDC
      |
      v
Kafka KRaft
      |
      v
Debezium JDBC Sink
      |
      v
MySQL
```

Technologies used:

- PostgreSQL WAL logical replication
- Debezium Change Data Capture
- Apache Kafka KRaft mode
- Kafka Connect
- MySQL synchronization
- Docker Compose