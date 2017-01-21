#!/bin/bash

PAYARA_DIR=/opt/payara41/glassfish/
#set -e

info () {
    echo "[INFO] $@"
}

appSetup () {

    info "Executing appSetup"
    #set security for admin console
    ${PAYARA_DIR}/bin/asadmin start-domain
    expect /tmp/setsecurity.expect
    ${PAYARA_DIR}/bin/asadmin stop-domain

    #change the domain.xml for mysql
    /tmp/changeconfig.sh

    sed -i "s/<mysql-user>/${MYSQL_USER}/g" ${PAYARA_DIR}/domains/domain1/config/domain.xml
    sed -i "s/<mysql-password>/${MYSQL_PASSWORD}/g" ${PAYARA_DIR}/domains/domain1/config/domain.xml
    sed -i "s/<mysql-server>/${MYSQL_SERVER}/g" ${PAYARA_DIR}/domains/domain1/config/domain.xml

    cd /home/letsencrypt/
    ./letsencrypt-auto certonly --standalone -w /home -d ${WEBURL} --preferred-challenges http -m ${EMAIL} --agree-tos
    cd /home
    ./installcertificate.sh ${WEBURL}

    touch /opt/payara41/glassfish/domains/.alreadysetup

}

appStart () {
    info "Executing appStart"
    [ -f /opt/payara41/glassfish/domains/.alreadysetup ] && echo "Skipping setup..." || appSetup

    # Start the services
    /usr/bin/supervisord
}

appHelp () {
	echo "Available options:"
	echo " app:start          - Starts all services needed for Samba AD DC"
	echo " app:setup          - First time setup."
	echo " app:help           - Displays the help"
	echo " [command]          - Execute the specified linux command eg. /bin/bash."
}

case "$1" in
	app:start)
		appStart
		;;
	app:setup)
		appSetup
		;;
	app:help)
		appHelp
		;;
	*)
		if [ -x $1 ]; then
			$1
		else
			prog=$(which $1)
			if [ -n "${prog}" ] ; then
				shift 1
				$prog $@
			else
				appHelp
			fi
		fi
		;;
esac

exit 0
