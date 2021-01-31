#!/usr/bin/env bash

export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:/jre/bin/java::")

#UNIFI_DIR="${UNIFI_DIR:-/unifi}"
#export UNIFI_DATA_DIR="${BASEDIR}/data"
#export UNIFI_LOG_DIR="${BASEDIR}/logs"

echo "unifi entrypoint by $(id -u)"
echo "  JAVA_HOME      = ${JAVA_HOME}"
echo "  UNIFI_DIR      = ${UNIFI_DIR}"
echo "  UNIFI_DATA_DIR = ${UNIFI_DATA_DIR}"
echo "  UNIFI_LOG_DIR  = ${UNIFI_LOG_DIR}"

mkdir -p -m 0755 ${UNIFI_DATA_DIR} ${UNIFI_LOG_DIR}
chown -R unifi ${UNIFI_DATA_DIR} ${UNIFI_LOG_DIR}

ln -sfn ${UNIFI_DATA_DIR} /usr/lib/unifi/data
ln -sfn ${UNIFI_LOG_DIR} /usr/lib/unifi/logs
ln -sfn /var/run/unifi /usr/lib/unifi/run

chown -h unifi:unifi /usr/lib/unifi/{data,logs,run}

exec "$@"
