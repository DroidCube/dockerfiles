FROM alpine

ENV OCSERV_VERSION=1.1.2
ENV OCSERV_URL=ftp://ftp.infradead.org/pub/ocserv/ocserv-$OCSERV_VERSION.tar.xz

RUN set -ex ; \
    apk add --update --virtual .build-deps \
        curl \
        g++ \
        gnutls-dev \
        gpgme \
        libev-dev \
        libnl3-dev \
        libseccomp-dev \
        linux-headers \
        linux-pam-dev \
        lz4-dev \
        make \
        readline-dev \
        tar \
        xz \
    ; \
    curl -SL $OCSERV_URL -o /ocserv.tar.xz ; \
    curl -SL $OCSERV_URL.sig -o /ocserv.tar.xz.sig ; \
    #gpg --keyserver pgp.mit.edu --recv-key 96865171 ; \
    gpg --keyserver pool.sks-keyservers.net --recv-key 29EE58B996865171 ; \
    gpg --verify /ocserv.tar.xz.sig ; \
    mkdir -p /usr/src/ocserv ; \
    tar -xf /ocserv.tar.xz -C /usr/src/ocserv --strip-components=1 ; \
    rm /ocserv.tar.xz* ; \
    cd /usr/src/ocserv ; ./configure ; make ; make install ; cd / ; \
    cp /usr/src/ocserv/doc/sample.config /usr/src/ocserv.conf.sample ; \
    rm -fr /usr/src/ocserv ; \
    export runDeps="$(scanelf --needed --nobanner /usr/local/*bin/* \
        | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
        | xargs -r apk info --installed \
        | sort -u | uniq \
    )" ; \
    apk add --virtual .run-deps $runDeps gnutls-utils iptables ; \
    apk del .build-deps ; \
    rm -rf /var/cache/apk/*

COPY *.sh /sbin/

# VPN address pool
ENV VPN_NETWORK=192.168.255.0/24
# no-route range
ENV LAN_NETWORK=10.0.0.0/8
#
ENV VPN_DOMAIN=vpn.easypi.pro
ENV VPN_USERNAME=username
ENV VPN_PASSWORD=password

VOLUME /etc/ocserv
WORKDIR /etc/ocserv

EXPOSE 443/tcp 443/udp

ENTRYPOINT ["/sbin/entrypoint.sh"]
