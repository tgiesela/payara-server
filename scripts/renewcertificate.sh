#!/bin/bash

ORIGDATE=`(stat -c %Y /etc/letsencrypt/live/portal.devosverzuimbeheer.nl/cert.pem)`
/home/letsencrypt/letsencrypt-auto renew --agree-tos
NEWDATE=`(stat -c %Y /etc/letsencrypt/live/portal.devosverzuimbeheer.nl/cert.pem)`

echo "New date=" ${NEWDATE}",Original date="${ORIGDATE}

if [ ${NEWDATE} == ${ORIGDATE} ]; then
     echo "Certificate not renewed"
else
     echo "Certificate has changed"
     echo "Installing the new certificate"
     /home/installcertificate.sh ${WEBURL}
fi
