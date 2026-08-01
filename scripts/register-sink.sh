#!/bin/bash

echo "Creating Debezium JDBC MySQL sink connector..."

curl -i \
-X POST \
-H "Content-Type: application/json" \
http://localhost:8083/connectors \
-d @connectors/mysql-sink.json

echo ""
echo "Sink connector created."