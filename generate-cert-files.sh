#!/bin/bash
# kafka ca, server and client cert generate for demo
#

GREEN='\033[0;32m'
NC='\033[0m' # No Color

# jks passwords to access contents
CLIPASS="clientpass"
SRVPASS="serversecret"

# CN for server and client
server1=kafka1
server2=kafka2
server3=kafka3

producer=kafkaproducer
consumer=kafkaconsumer

# server1=localhost
# server2=localhost
# server3=localhost
# producer=localhost
# consumer=localhost

echo "Clearing existing Kafka SSL certs..."
rm -rf ssl
mkdir ssl

(
cd ssl

# CA certificates
echo -e "${GREEN}Generating ca-cert & ca-key for the demo...${NC}"
mkdir ca && cd ca
openssl req -new -newkey rsa:4096 -days 365 -x509 -subj "/C=IN/ST=KA/L=Bangalore/O=None/OU=None/CN=kafka.ssl" -keyout ca-key -out ca-cert -nodes
cd ..

# Server certificates
echo -e "${GREEN}Generating server keystore & truststore for the demo...${NC}"
mkdir server && cd server

echo -e "${GREEN}Generating server keystores...${NC}"
keytool -genkey -keystore kafka.server1.keystore.jks -validity 365 -storepass $SRVPASS -keypass $SRVPASS  -dname "CN=${server1}, OU=None, O=None, L=Bangalore, ST=KA, C=IN" -storetype pkcs12
keytool -genkey -keystore kafka.server2.keystore.jks -validity 365 -storepass $SRVPASS -keypass $SRVPASS  -dname "CN=${server2}, OU=None, O=None, L=Bangalore, ST=KA, C=IN" -storetype pkcs12
keytool -genkey -keystore kafka.server3.keystore.jks -validity 365 -storepass $SRVPASS -keypass $SRVPASS  -dname "CN=${server3}, OU=None, O=None, L=Bangalore, ST=KA, C=IN" -storetype pkcs12

echo -e "${GREEN}Generating server request files...${NC}"
keytool -keystore kafka.server1.keystore.jks -certreq -file cert-file1 -storepass $SRVPASS -keypass $SRVPASS
keytool -keystore kafka.server2.keystore.jks -certreq -file cert-file2 -storepass $SRVPASS -keypass $SRVPASS
keytool -keystore kafka.server3.keystore.jks -certreq -file cert-file3 -storepass $SRVPASS -keypass $SRVPASS

echo -e "${GREEN}Signing the server request files with ca-cert...${NC}"
openssl x509 -req -CA ../ca/ca-cert -CAkey ../ca/ca-key -in cert-file1 -out cert-signed1 -days 365 -CAcreateserial -passin pass:$SRVPASS
openssl x509 -req -CA ../ca/ca-cert -CAkey ../ca/ca-key -in cert-file2 -out cert-signed2 -days 365 -CAcreateserial -passin pass:$SRVPASS
openssl x509 -req -CA ../ca/ca-cert -CAkey ../ca/ca-key -in cert-file3 -out cert-signed3 -days 365 -CAcreateserial -passin pass:$SRVPASS

echo -e "${GREEN}Importing ca to server keystores...${NC}"
keytool -keystore kafka.server1.keystore.jks -alias CARoot -import -file ../ca/ca-cert -storepass $SRVPASS -keypass $SRVPASS -noprompt
keytool -keystore kafka.server2.keystore.jks -alias CARoot -import -file ../ca/ca-cert -storepass $SRVPASS -keypass $SRVPASS -noprompt
keytool -keystore kafka.server3.keystore.jks -alias CARoot -import -file ../ca/ca-cert -storepass $SRVPASS -keypass $SRVPASS -noprompt

echo -e "${GREEN}Importing signed server certs to server keystores...${NC}"
keytool -keystore kafka.server1.keystore.jks -import -file cert-signed1 -storepass $SRVPASS -keypass $SRVPASS -noprompt
keytool -keystore kafka.server2.keystore.jks -import -file cert-signed2 -storepass $SRVPASS -keypass $SRVPASS -noprompt
keytool -keystore kafka.server3.keystore.jks -import -file cert-signed3 -storepass $SRVPASS -keypass $SRVPASS -noprompt

echo -e "${GREEN}Generating server truststore...${NC}"
keytool -keystore kafka.server.truststore.jks -alias CARoot -import -file ../ca/ca-cert -storepass $SRVPASS -keypass $SRVPASS -noprompt

echo -e "${GREEN}Removing server request and signed files...${NC}"
rm cert-file*
rm cert-signed*

cd ..

# Client certificates
echo -e "${GREEN}Generating client keystore & truststore for the demo...${NC}"
mkdir client && cd client

echo -e "${GREEN}Generating client truststore...${NC}"
keytool -keystore kafka.client.truststore.jks -alias CARoot -import -file ../ca/ca-cert  -storepass $CLIPASS -keypass $CLIPASS -noprompt

echo -e "${GREEN}Generating client keystores...${NC}"
keytool -genkey -keystore kafka.producer.keystore.jks -validity 365 -storepass $CLIPASS -keypass $CLIPASS  -dname "CN=${producer}, OU=None, O=None, L=Bangalore, ST=KA, C=IN" -alias kafka-producer -storetype pkcs12
keytool -genkey -keystore kafka.consumer.keystore.jks -validity 365 -storepass $CLIPASS -keypass $CLIPASS  -dname "CN=${consumer}, OU=None, O=None, L=Bangalore, ST=KA, C=IN" -alias kafka-consumer -storetype pkcs12

echo -e "${GREEN}Generating client request files...${NC}"
keytool -keystore kafka.producer.keystore.jks -certreq -file producer-cert-sign-request -alias kafka-producer -storepass $CLIPASS -keypass $CLIPASS
keytool -keystore kafka.consumer.keystore.jks -certreq -file consumer-cert-sign-request -alias kafka-consumer -storepass $CLIPASS -keypass $CLIPASS

echo -e "${GREEN}Signing the client request files with ca-cert...${NC}"
openssl x509 -req -CA ../ca/ca-cert -CAkey ../ca/ca-key -in producer-cert-sign-request -out producer-cert-signed -days 365 -CAcreateserial -passin pass:$SRVPASS
openssl x509 -req -CA ../ca/ca-cert -CAkey ../ca/ca-key -in consumer-cert-sign-request -out consumer-cert-signed -days 365 -CAcreateserial -passin pass:$SRVPASS

echo -e "${GREEN}Importing ca cert to server keystores...${NC}"
keytool -keystore kafka.producer.keystore.jks -alias CARoot -import -file ../ca/ca-cert -storepass $CLIPASS -keypass $CLIPASS -noprompt
keytool -keystore kafka.consumer.keystore.jks -alias CARoot -import -file ../ca/ca-cert -storepass $CLIPASS -keypass $CLIPASS -noprompt

echo -e "${GREEN}Importing signed client certs to server keystores...${NC}"
keytool -keystore kafka.producer.keystore.jks -import -file producer-cert-signed -alias kafka-producer -storepass $CLIPASS -keypass $CLIPASS -noprompt
keytool -keystore kafka.consumer.keystore.jks -import -file consumer-cert-signed -alias kafka-consumer -storepass $CLIPASS -keypass $CLIPASS -noprompt

echo -e "${GREEN}Removing client request and signed files...${NC}"
rm *-sign-request
rm *-cert-signed

cd ../../

echo -e "${GREEN}Copying producer keystore and truststore to producer folder...${NC}"
cp ./ssl/client/kafka.client.truststore.jks ./producer
cp ./ssl/client/kafka.producer.keystore.jks ./producer

echo -e "${GREEN}Copying consumer keystore and truststore to consumer folder...${NC}"
cp ./ssl/client/kafka.client.truststore.jks ./consumer
cp ./ssl/client/kafka.consumer.keystore.jks ./consumer

cp ./ssl/client/kafka.client.truststore.jks ./wrongclient

echo -e "${GREEN}Copying server keystore and truststore to server folder...${NC}"
mkdir -p ./kafka1/config/ssl
mkdir -p ./kafka2/config/ssl
mkdir -p ./kafka3/config/ssl
cp ./ssl/server/kafka.server.truststore.jks ./kafka1/config/ssl
cp ./ssl/server/kafka.server.truststore.jks ./kafka2/config/ssl
cp ./ssl/server/kafka.server.truststore.jks ./kafka3/config/ssl

cp ./ssl/server/kafka.server1.keystore.jks ./kafka1/config/ssl
cp ./ssl/server/kafka.server2.keystore.jks ./kafka2/config/ssl
cp ./ssl/server/kafka.server3.keystore.jks ./kafka3/config/ssl

)
