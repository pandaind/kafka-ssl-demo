#!/bin/bash
# remove all cert files from the demo folder
#

GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}Removing all the cert files from this demo folder...${NC}"

rm -rf ssl
cd producer && rm *.jks && cd ..
cd consumer && rm *.jks && cd ..
cd wrongclient && rm *.jks && cd ..
rm -rf ./kafka1/config/ssl
rm -rf ./kafka2/config/ssl
rm -rf ./kafka3/config/ssl

echo -e "${GREEN}All cert files removed...${NC}"