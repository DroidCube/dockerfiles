FROM ubuntu:20.04

ENV UNIFIVER=6.0.45 \
    PKGSHA1=0496aaa11f1a2a8e875ed172f16d9178db3a4c9b \
    UNIFI_DIR=/unifi \
    UNIFI_DATA_DIR=/unifi/data \
    UNIFI_LOG_DIR=/unifi/logs

RUN set -ex ; \
    # apt update / install
    apt-get update ; apt-get upgrade -y ; \
    apt-get install -y --no-install-recommends \
        adduser binutils coreutils curl gosu jsvc libcap2 logrotate procps wget \
        mongodb-server openjdk-8-jre-headless \
    ; \
    # install from deb file with sha1 check
    export PKGFILE=unifi_sysvinit_all.deb ; \
    export PKGURL=http://dl.ubnt.com/unifi/${UNIFIVER}/${PKGFILE} ; \
    wget ${PKGURL} ; \
    echo "$PKGSHA1 /$PKGFILE" | sha1sum -c - ; \
    dpkg -i /${PKGFILE} ; rm /${PKGFILE} ; \
    apt-get clean ; \
    rm -fr /var/lib/apt/lists/*

COPY *.sh /usr/local/bin/
COPY unifi.default /etc/default/unifi

EXPOSE 6789/tcp 8080/tcp 8443/tcp 8843/tcp 8880/tcp \
       3478/udp 10001/udp

VOLUME /unifi

ENTRYPOINT ["entrypoint.sh"]
CMD ["gosu", "unifi", "unifi.init.sh"]
