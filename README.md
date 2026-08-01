# PostgreSQL → Debezium → Kafka KRaft → MySQL CDC

A complete Change Data Capture (CDC) example using:

- PostgreSQL 16
- Debezium 3.2
- Apache Kafka 3.9 (KRaft mode - no ZooKeeper)
- Kafka Connect
- Debezium JDBC Sink Connector
- MySQL 8.4

---

## Architecture

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

# Project Structure

```
postgres-debezium-mysql-cdc/

├── docker-compose.yml

├── README.md

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
    └── test.sh
```

---

# Requirements

Install:

- Docker
- Docker Compose

Check versions:

```bash
docker --version
docker compose version
```

---

# Start the Environment

## 1. Build containers

```bash
docker compose build
```

---

## 2. Start services

```bash
docker compose up -d
```

---

## 3. Check containers

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

# Register Debezium PostgreSQL Source Connector

Run:

```bash
./scripts/register-source.sh
```

Expected response:

```json
{
  "name": "postgres-source"
}
```

---

# Register MySQL Sink Connector

Run:

```bash
./scripts/register-sink.sh
```

Expected response:

```json
{
  "name": "mysql-sink"
}
```

---

# Verify Connectors

List connectors:

```bash
curl http://localhost:8083/connectors
```

Expected:

```json
[
  "postgres-source",
  "mysql-sink"
]
```

---

## Check Source Status

```bash
curl \
http://localhost:8083/connectors/postgres-source/status
```

---

## Check Sink Status

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

1. Insert into PostgreSQL
2. Debezium captures WAL change
3. Kafka receives CDC event
4. JDBC Sink writes to MySQL

Then:

1. Update PostgreSQL
2. MySQL is updated

Then:

1. Delete PostgreSQL row
2. MySQL row is removed

---

# Manual CDC Test

## Connect to PostgreSQL

```bash
docker exec -it cdc-postgres \
psql -U postgres -d inventory
```

Insert:

```sql
INSERT INTO customers(name,email)
VALUES
('Test User','test@example.com');
```

---

## Check MySQL

Connect:

```bash
docker exec -it cdc-mysql \
mysql -uroot -proot inventory
```

Query:

```sql
SELECT * FROM customers;
```

Expected:

```
+----+-----------+-------------------+
| id | name      | email             |
+----+-----------+-------------------+
|  1 | Test User | test@example.com  |
+----+-----------+-------------------+
```

---

# Kafka Topic

Debezium creates:

```
postgres.public.customers
```

List Kafka topics:

```bash
docker exec -it cdc-kafka \
kafka-topics.sh \
--bootstrap-server localhost:9092 \
--list
```

---

# PostgreSQL CDC Configuration

PostgreSQL must have logical replication enabled:

```
wal_level=logical
```

This is configured automatically in:

```
docker-compose.yml
```

---

# Kafka Configuration

This project uses:

```
Kafka KRaft Mode
```

ZooKeeper is not required.

Kafka manages metadata using its own Raft quorum.

---

# Useful Ports

| Service | Port |
|---|---:|
| PostgreSQL | 5432 |
| MySQL | 3306 |
| Kafka | 9092 |
| Kafka Connect REST | 8083 |

---

# Stop Environment

Stop containers:

```bash
docker compose down
```

Remove data volumes:

```bash
docker compose down -v
```

---

# Troubleshooting

## Check Kafka Connect logs

```bash
docker logs cdc-connect
```

---

## Check PostgreSQL logs

```bash
docker logs cdc-postgres
```

---

## Check MySQL logs

```bash
docker logs cdc-mysql
```

---

## Restart everything

```bash
docker compose down

docker compose up -d --build
```

---

# Production Improvements

For production deployments consider:

- Multiple Kafka brokers
- TLS encryption
- Kafka authentication
- Schema Registry
- Connector secrets management
- Monitoring with Prometheus/Grafana
- Dead Letter Queue handling
- Backup strategy
- Kubernetes deployment

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

## Highlights

- Kafka runs in KRaft mode without ZooKeeper.
- PostgreSQL changes are captured using WAL logical replication.
- Debezium provides CDC event streaming.
- Kafka transports change events.
- MySQL receives replicated data through the Debezium JDBC Sink Connector.