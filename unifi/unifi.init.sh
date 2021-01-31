#!/bin/bash
#
# /etc/init.d/UniFi -- startup script for Ubiquiti UniFi
#
#


dir_symlink_fix() {
	UNIFI_USER=$1
	DSTDIR=$2
	SYMLINK=$3

	[ -d ${DSTDIR} ] || install -o ${UNIFI_USER} -d ${DSTDIR}
	[ -d ${SYMLINK} -a ! -L ${SYMLINK} ] && mv ${SYMLINK} `mktemp -u ${SYMLINK}.XXXXXXXX`
	[ "$(readlink ${SYMLINK})" = "${DSTDIR}" ] || (rm -f ${SYMLINK} && ln -sf ${DSTDIR} ${SYMLINK})
	chown -h ${UNIFI_USER} ${SYMLINK}
}

file_symlink_fix() {
	UNIFI_USER=$1
	DSTFILE=$2
	SYMLINK=$3

	if [ -f ${DSTFILE} ]; then
		[ -f ${SYMLINK} -a ! -L ${SYMLINK} ] && mv ${SYMLINK} `mktemp -u ${SYMLINK}.XXXXXXXX`
		[ "$(readlink ${SYMLINK})" = "${DSTFILE}" ] || (rm -f ${SYMLINK} && ln -sf ${DSTFILE} ${SYMLINK})
		chown -h ${UNIFI_USER} ${SYMLINK}
	fi
}

NAME="unifi"
DESC="Ubiquiti UniFi Controller"

BASEDIR="/usr/lib/unifi"

PATH=/bin:/usr/bin:/sbin:/usr/sbin

CODEPATH=${BASEDIR}
DATALINK=${BASEDIR}/data
LOGLINK=${BASEDIR}/logs
RUNLINK=${BASEDIR}/run

JAVA_ENTROPY_GATHER_DEVICE=
JVM_MAX_HEAP_SIZE=1024M
JVM_INIT_HEAP_SIZE=
UNIFI_JVM_EXTRA_OPTS=

JVM_EXTRA_OPTS=
[ -f /etc/default/${NAME} ] && . /etc/default/${NAME}

DATADIR=${UNIFI_DATA_DIR:-/var/lib/${NAME}}
LOGDIR=${UNIFI_LOG_DIR:-/var/log/${NAME}}
RUNDIR=${UNIFI_RUN_DIR:-/var/run/${NAME}}

JVM_EXTRA_OPTS="${JVM_EXTRA_OPTS} -Dunifi.datadir=${DATADIR} -Dunifi.logdir=${LOGDIR} -Dunifi.rundir=${RUNDIR}"

if [ ! -z "${JAVA_ENTROPY_GATHER_DEVICE}" ]; then
	JVM_EXTRA_OPTS="${JVM_EXTRA_OPTS} -Djava.security.egd=${JAVA_ENTROPY_GATHER_DEVICE}"
fi

if [ ! -z "${JVM_MAX_HEAP_SIZE}" ]; then
	JVM_EXTRA_OPTS="${JVM_EXTRA_OPTS} -Xmx${JVM_MAX_HEAP_SIZE}"
fi

if [ ! -z "${JVM_INIT_HEAP_SIZE}" ]; then
	JVM_EXTRA_OPTS="${JVM_EXTRA_OPTS} -Xms${JVM_INIT_HEAP_SIZE}"
fi

if [ ! -z "${UNIFI_JVM_EXTRA_OPTS}" ]; then
	JVM_EXTRA_OPTS="${JVM_EXTRA_OPTS} ${UNIFI_JVM_EXTRA_OPTS}"
fi

JVM_OPTS="${JVM_EXTRA_OPTS} -Djava.awt.headless=true -Dfile.encoding=UTF-8"

UNIFI_USER=${UNIFI_USER:-unifi}

# fix path for ace
dir_symlink_fix ${UNIFI_USER} ${DATADIR} ${DATALINK}
dir_symlink_fix ${UNIFI_USER} ${LOGDIR} ${LOGLINK}
dir_symlink_fix ${UNIFI_USER} ${RUNDIR} ${RUNLINK}
[ -z "${UNIFI_SSL_KEYSTORE}" ] || file_symlink_fix ${UNIFI_USER} ${UNIFI_SSL_KEYSTORE} ${DATALINK}/keystore

UNIFI_UID=$(id -u ${UNIFI_USER})
DATADIR_UID=$(stat ${DATADIR} -Lc %u)
if [ ${UNIFI_UID} -ne ${DATADIR_UID} ]; then
	msg="${NAME} cannot start. Please create ${UNIFI_USER} user, and chown -R ${UNIFI_USER} ${DATADIR} ${LOGDIR} ${RUNDIR}"
	logger $msg
	echo $msg >&2
	exit 1
fi

cd ${BASEDIR}

java ${JVM_OPTS} -jar ${BASEDIR}/lib/ace.jar start

exit 0
