#!/bin/bash


echo "================================="
echo "PostgreSQL Source Connector"
echo "================================="

curl -s \
http://localhost:8083/connectors/postgres-source/status


echo ""


echo "================================="
echo "MySQL Sink Connector"
echo "================================="

curl -s \
http://localhost:8083/connectors/mysql-sink/status


echo ""