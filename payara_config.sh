#!/bin/bash
read -p "Password for payara admin user: " ADMIN_PASSWORD
read -p "User to connect to mysql-database: " MYSQL_USER
read -p "Password for mysql ${MYSQL_USER} user: " ROOT_PASSWORD
read -p "Hostname or ip-address mysql-server: " MYSQL_SERVER
read -p "DNS-servername: " DNS_IP_ADDRESS
read -p "Hostname-part of web-url for Letsencrypt certificate: " WEBURL
read -p "E-mail address for Letsencrypt warnings: " EMAIL

read -p "Do you want to use custom network? (y/n) " yn
case $yn in
    [Yy]* )
            read -p "Custom network name : " CUSTOMNETWORKNAME
            if  [ -z $CUSTOMNERWORKNAME ]; then
                   CUSTOMNETWORK="--net ${CUSTOMNETWORKNAME}"
            fi;;
        * ) CUSTOMNETWORK=
            ;;
esac

read -p "Fixed ip-address for payara server: " FIXED_IP_ADDRESS
if [ -z $FIXED_IP_ADDRESS ]; then
    FIXED_IP_ADDRESS=
else
    FIXED_IP_ADDRESS=--ip=${FIXED_IP_ADDRESS}
fi

docker run \
	-e PAYARA_ADMIN_PASSWORD="${ADMIN_PASSWORD}" \
	-e MYSQL_USER="${MYSQL_USER}" \
	-e MYSQL_PASSWORD="${ROOT_PASSWORD}" \
	-e MYSQL_SERVER="${MYSQL_SERVER}" \
	-e WEBURL=${WEBURL} \
	-e EMAIL=${EMAIL} \
	--dns=${DNS_IP_ADDRESS} \
	-h payara \
	${FIXED_IP_ADDRESS} \
	--name payara \
	${CUSTOMNETWORK} \
	-p:4848:4848 \
	-p:443:8181 \
	-p:80:80 \
	-d \
	tgiesela/payara:v0.1 




