Demo
=====

```bash
docker-compose down && docker-compose up -d
```

local client
------------

```bash
~/kafka/bin/kafka-topics.sh --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic kafka-security-topic --create
```

```bash
~/kafka/bin/kafka-topics.sh --describe --topic kafka-security-topic --zookeeper zookeeper:2181
```

```bash
~/kafka/bin/kafka-console-producer.sh --broker-list localhost:9093 --topic kafka-security-topic --producer.config ./producer/local_client.properties
```

```bash
~/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9093 --topic kafka-security-topic --from-beginning --consumer.config ./consumer/local_client.properties
```

##### wrong local client

```bash
~/kafka/bin/kafka-console-producer.sh --broker-list localhost:9093 --topic kafka-security-topic --producer.config ./wrongclient/local_client.properties
```

```bash
~/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9093 --topic kafka-security-topic --from-beginning --consumer.config ./wrongclient/local_client.properties
```

docker client without ssl
-------------------------

```bash
docker run --net=kafka-ssl-demo_default --rm strimzi/kafka:latest ./bin/kafka-topics.sh --zookeeper zookeeper:2181 --replication-factor 1 --partitions 1 --topic kafka-security-topic --create
```

```bash
docker run --net=kafka-ssl-demo_default --rm strimzi/kafka:latest ./bin/kafka-topics.sh --describe --topic kafka-security-topic --zookeeper zookeeper:2181
```

```bash
docker run --net=kafka-ssl-demo_default --rm strimzi/kafka:latest ./bin/kafka-console-consumer.sh --bootstrap-server kafka1:19092 --topic kafka-security-topic --from-beginning
```

```bash
docker run --net=kafka-ssl-demo_default --rm -ti strimzi/kafka:latest ./bin/kafka-console-producer.sh --broker-list kafka1:19092 --topic kafka-security-topic
```

docker client with ssl (Change certificate CN and advertised.listeners)
----------------------

```bash
docker run --net=kafka-ssl-demo_default --rm strimzi/kafka:latest openssl s_client -connect kafka1:9093
```

```bash
docker run --net=kafka-ssl-demo_default --rm strimzi/kafka:latest ./bin/kafka-topics.sh --zookeeper zookeeper:2181 --replication-factor 1 --partitions 1 --topic kafka-security-topic --create
```

```bash
docker run --net=kafka-ssl-demo_default --rm strimzi/kafka:latest ./bin/kafka-topics.sh --describe --topic kafka-security-topic --zookeeper zookeeper:2181
```

```bash
docker run --net=kafka-ssl-demo_default --hostname localhost --volume "$(pwd)/producer":/opt/kafka/config/producer --rm -ti strimzi/kafka:latest ./bin/kafka-console-producer.sh --broker-list kafka1:9093 --topic kafka-security-topic --producer.config ./config/producer/client.properties
```

```bash
docker run --net=kafka-ssl-demo_default --hostname kafka-consumer --volume "$(pwd)/consumer":/opt/kafka/config/consumer --rm strimzi/kafka:latest ./bin/kafka-console-consumer.sh --bootstrap-server kafka1:9093 --topic kafka-security-topic --from-beginning --consumer.config ./config/consumer/client.properties
```

##### docker wrong client with  (Change certificate CN and advertised.listeners)

```bash
docker run --net=kafka-ssl-demo_default --hostname localhost --volume "$(pwd)/wrongclient":/opt/kafka/config/wrongclient --rm -ti strimzi/kafka:latest ./bin/kafka-console-producer.sh --broker-list kafka1:9093 --topic kafka-security-topic --producer.config ./config/wrongclient/client.properties
```

```bash
docker run --net=kafka-ssl-demo_default --hostname localhost --volume "$(pwd)/wrongclient":/opt/kafka/config/wrongclient --rm strimzi/kafka:latest ./bin/kafka-console-consumer.sh --bootstrap-server kafka1:9093 --topic kafka-security-topic --from-beginning --consumer.config ./config/wrongclient/client.properties
```

ACL
----

```bash
~/kafka/bin/kafka-topics.sh --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic kafka-acl-topic --create
```

```bash
~/kafka/bin/kafka-acls.sh --authorizer kafka.security.auth.SimpleAclAuthorizer --authorizer-properties zookeeper.connect=localhost:2181 --add --allow-principal User:kafkaproducer --operation Write --topic kafka-acl-topic
```

```bash
~/kafka/bin/kafka-acls.sh --authorizer kafka.security.auth.SimpleAclAuthorizer --authorizer-properties zookeeper.connect=localhost:2181 --add --allow-principal User:kafkaconsumer --operation Read --topic kafka-acl-topic
```

###### WRONG ACL

```bash
docker run --net=kafka-ssl-demo_default --hostname kafkaconsumer --volume "$(pwd)/consumer":/opt/kafka/config/consumer --rm -ti strimzi/kafka:latest ./bin/kafka-console-producer.sh --broker-list kafka1:9093 --topic kafka-acl-topic --producer.config ./config/consumer/client.properties
```

```bash
docker run --net=kafka-ssl-demo_default --hostname kafkaproducer --volume "$(pwd)/producer":/opt/kafka/config/producer --rm strimzi/kafka:latest ./bin/kafka-console-consumer.sh --bootstrap-server kafka1:9093 --topic kafka-acl-topic --from-beginning --consumer.config ./config/producer/client.properties
```

###### CORRECT ACL

```bash
docker run --net=kafka-ssl-demo_default --hostname kafkaproducer --volume "$(pwd)/producer":/opt/kafka/config/producer --rm -ti strimzi/kafka:latest ./bin/kafka-console-producer.sh --broker-list kafka1:9093 --topic kafka-acl-topic --producer.config ./config/producer/client.properties
```

```bash
docker run --net=kafka-ssl-demo_default --hostname kafkaconsumer --volume "$(pwd)/consumer":/opt/kafka/config/consumer --rm strimzi/kafka:latest ./bin/kafka-console-consumer.sh --bootstrap-server kafka1:9093 --topic kafka-acl-topic --from-beginning --consumer.config ./config/consumer/client.properties
```
