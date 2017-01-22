#!/bin/bash
me="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"

if [ `id -u` -ne 0 ]
then
        echo "This script requires administrator privileges. Run with sudo."
        echo ""
        echo "Usage: sudo ./$me"
        echo ""
        exit 1
fi
if [ -z "$1" ];  then
    WEBURL=example.com
else
    WEBURL=$1
fi

INSTALLDIR=/opt/payara41/glassfish
DOMAIN=${WEBURL} # your domain name
KEYSTOREPW=changeit # The password given to the Glassfish Keystore. The same as the GF Admin password.
CERTSTORE=${INSTALLDIR}/domains/domain1/config/cacerts.jks # ie. ...glassfish/domains/domain1/config/keystore.jks
KEYSTORE=${INSTALLDIR}/domains/domain1/config/keystore.jks # ie. ...glassfish/domains/domain1/config/keystore.jks
LIVE=/etc/letsencrypt/live/$DOMAIN
ALIAS=${DOMAIN}

mkdir LEtemp
cd LEtemp

cp -f $KEYSTORE $KEYSTORE.old

STOREPASS="-srcstorepass $KEYSTOREPW -deststorepass $KEYSTOREPW -destkeypass $KEYSTOREPW"

echo "- Removing old keys"
keytool -delete -alias ${ALIAS} -keystore $KEYSTORE -storepass $KEYSTOREPW
#keytool -delete -alias root -keystore $KEYSTORE -storepass $KEYSTOREPW
#keytool -delete -alias glassfish-instance -keystore $KEYSTORE -storepass $KEYSTOREPW
#keytool -delete -alias s1as -keystore $KEYSTORE -storepass $KEYSTOREPW

# List current contents of kestore
keytool -list -keystore $KEYSTORE -storepass $KEYSTOREPW

echo "- Converting .pem files to .crt"
openssl x509 -outform der -in $LIVE/cert.pem -out $LIVE/cert.crt
openssl x509 -outform der -in $LIVE/chain.pem -out $LIVE/chain.crt
cat $LIVE/chain.crt $LIVE/cert.crt > $LIVE/all.crt

echo "- Importing new certs"
keytool -import -noprompt -trustcacerts -alias letsencrypt -file $LIVE/chain.crt $STOREPASS -keystore $CERTSTORE

echo "- Importing new keys"
openssl pkcs12 -export -in $LIVE/cert.pem -inkey $LIVE/privkey.pem -out cert_and_key.p12 -name $ALIAS -CAfile $LIVE/chain.crt -password pass:$KEYSTOREPW
keytool -importkeystore -destkeystore $KEYSTORE -srckeystore cert_and_key.p12 -srcstoretype PKCS12 -alias $ALIAS $STOREPASS
keytool -importcert -noprompt -alias $ALIAS -file $LIVE/all.crt -keystore $KEYSTORE $STOREPASS

keytool -list -keystore $KEYSTORE -storepass $KEYSTOREPW

echo ""
echo "- Cleaning up"

cd ..
rm -rf LEtemp

echo ""
echo "- Restarting Glassfish Service"
echo ""

${INSTALLDIR}/bin/asadmin restart-domain

