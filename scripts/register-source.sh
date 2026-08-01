#!/bin/bash

echo "Creating Debezium PostgreSQL source connector..."

curl -i \
-X POST \
-H "Content-Type: application/json" \
http://localhost:8083/connectors \
-d @connectors/postgres-source.json

echo ""
echo "Source connector created."