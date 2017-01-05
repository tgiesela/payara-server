#!/bin/bash

read -p "Password for payara admin user: " ADMIN_PASSWORD
read -p "User to connect to mysql-database: " MYSQL_USER
read -p "Password for mysql ${MYSQL_USER} user: " ROOT_PASSWORD
read -p "Hostname or ip-address mysql-server: " MYSQL_SERVER

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

docker run \
	-e PAYARA_ADMIN_PASSWORD="${ADMIN_PASSWORD}" \
	-e MYSQL_USER="${MYSQL_USER}" \
	-e MYSQL_PASSWORD="${ROOT_PASSWORD}" \
	-e MYSQL_SERVER="${MYSQL_SERVER}" \
	-h payara \
	--name payara \
	${CUSTOMNETWORK} \
	-p:4848:4848 \
	-d \
	tonny/payara:v0.1 




