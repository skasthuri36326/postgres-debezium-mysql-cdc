#!/bin/bash

echo "Removing existing PostgreSQL source connector..."

curl -s -X DELETE \
http://localhost:8083/connectors/postgres-source


sleep 3


echo "Creating PostgreSQL source connector..."

curl -i \
-X POST \
-H "Content-Type: application/json" \
-d @connectors/postgres-source.json \
http://localhost:8083/connectors


echo ""
echo "PostgreSQL source connector created."