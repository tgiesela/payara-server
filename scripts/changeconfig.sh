#!/bin/bash
CONFIGDIR=/opt/payara41/glassfish/domains/domain1/config

#Insert the contents of the jdbc_resource.xml file into the domain.xml
sed '/<\/resources>/{h
r /tmp/jdbc_resource.xml
g
N
}' ${CONFIGDIR}/domain.xml > ${CONFIGDIR}/newdomain.xml

rm ${CONFIGDIR}/domain.xml
mv ${CONFIGDIR}/newdomain.xml ${CONFIGDIR}/domain.xml
