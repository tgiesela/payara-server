FROM ubuntu:16.04
MAINTAINER Tonny Gieselaar <tonny@devosverzuimbeheer.nl>

ENV DEBIAN_FRONTEND noninteractive
ENV PAYARA_ADMIN_PASSWORD=""

# Setup ssh and install supervisord
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y openssh-server supervisor \
        net-tools nano apt-utils wget \
        dnsutils iputils-ping expect

# Install java

RUN apt-get update
RUN apt-get install -y default-jdk
RUN apt-get install -y unzip
ADD payara-4.1.1.164.zip /tmp/payara.zip
RUN unzip /tmp/payara.zip -d /opt/

# ear/war to deploy automatically are store in apps/
ADD apps/ /opt/payara41/glassfish/domains/domain1/autodeploy/
# additional drivers like a mysql driver
ADD drivers/ /opt/payara41/glassfish/domains/domain1/lib/ext/


ADD config/jdbc_resource.xml /tmp/
ADD scripts/changeconfig.sh /tmp/

# Create folder for ssh and supervisor
RUN mkdir -p /var/run/sshd
RUN mkdir -p /var/log/supervisor

ADD config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD scripts/setsecurity.expect /tmp/
ADD scripts/init.sh /init.sh

# Additional things for Letsencrypt certificates
RUN apt-get install -y git
RUN cd /home && git clone https://github.com/letsencrypt/letsencrypt
ADD scripts/installcertificate.sh /home/
ADD scripts/renewcertificate.sh /home/

RUN apt-get clean

RUN chmod 755 /init.sh
EXPOSE 4848 443 
ENTRYPOINT ["/init.sh"]
CMD ["app:start"]

