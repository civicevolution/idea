#!/sbin/runscript
# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

REDISTOGO_URL='http://brian:123@ec2-50-18-101-127.us-west-1.compute.amazonaws.com:6379'
PATH=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/bin
DESC="Juggernaut on node.js service"
NODEUSER=brian:brian
PIDFILE=/var/run/juggernaut.pid
LOCAL_VAR_RUN=/var/run
NAME=juggernaut
DAEMON=/usr/local/bin/$NAME
LOGFILE=/var/log/node-service.log
NCMD="exec $DAEMON >>$LOGFILE 2>&1"

#depend() {
#
#}

start() {
        ebegin "Starting juggernaut"

 start-stop-daemon --start --quiet --chuid $NODEUSER --make-pidfile --pidfile $PIDFILE --background \
     --startas /bin/sh -- -c "REDISTOGO_URL='${REDISTOGO_URL}' ${DAEMON} >> ${LOGFILE} 2>&1"
        eend $?

}

stop() {
        ebegin "Stopping juggernaut"
        start-stop-daemon --stop --quiet --name node
        start-stop-daemon --stop --quiet --pidfile "${PIDFILE}"
        rm -f "${PIDFILE}"

        eend $?
}

restart() {
        svc_stop
        svc_start
}



