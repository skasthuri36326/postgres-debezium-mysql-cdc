#!/bin/bash

echo "Removing existing MySQL sink connector..."

curl -s -X DELETE \
http://localhost:8083/connectors/mysql-sink


sleep 3


echo "Creating MySQL sink connector..."

curl -i \
-X POST \
-H "Content-Type: application/json" \
-d @connectors/mysql-sink.json \
http://localhost:8083/connectors


echo ""
echo "MySQL sink connector created."