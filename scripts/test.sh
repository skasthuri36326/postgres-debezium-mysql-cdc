#!/bin/bash

echo "=== PostgreSQL -> Debezium -> Kafka -> MySQL CDC Test ==="


echo ""
echo "Insert test record"


docker exec -it cdc-postgres \
psql -U postgres -d inventory \
-c "
INSERT INTO customers(name,email)
VALUES('CDC User','cdc@test.com');
"


sleep 5


echo ""
echo "Checking MySQL"


docker exec -it cdc-mysql \
mysql -uroot -proot inventory \
-e "
SELECT * FROM customers;
"



echo ""
echo "Update test record"


docker exec -it cdc-postgres \
psql -U postgres -d inventory \
-c "
UPDATE customers
SET name='CDC Updated User'
WHERE email='cdc@test.com';
"


sleep 5


docker exec -it cdc-mysql \
mysql -uroot -proot inventory \
-e "
SELECT * FROM customers
WHERE email='cdc@test.com';
"



echo ""
echo "Delete test record"


docker exec -it cdc-postgres \
psql -U postgres -d inventory \
-c "
DELETE FROM customers
WHERE email='cdc@test.com';
"


sleep 5


docker exec -it cdc-mysql \
mysql -uroot -proot inventory \
-e "
SELECT * FROM customers
WHERE email='cdc@test.com';
"


echo ""
echo "CDC test completed."