FROM quay.io/debezium/connect:3.2


USER root


# Install Debezium JDBC Sink Connector

RUN mkdir -p /kafka/connect/debezium-jdbc


RUN curl -L \
https://repo1.maven.org/maven2/io/debezium/debezium-connector-jdbc/3.2.0.Final/debezium-connector-jdbc-3.2.0.Final-plugin.tar.gz \
-o /tmp/debezium-jdbc.tar.gz \
&& tar -xzf /tmp/debezium-jdbc.tar.gz \
-C /kafka/connect/debezium-jdbc \
&& rm /tmp/debezium-jdbc.tar.gz



# Install MySQL JDBC driver

RUN curl -L \
https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/9.0.0/mysql-connector-j-9.0.0.jar \
-o /kafka/connect/debezium-jdbc/mysql-connector-j.jar



USER kafka