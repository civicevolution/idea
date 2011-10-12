#! /bin/sh
### BEGIN INIT INFO
# Provides: juggernaut2
# Required-Start: $syslog $remote_fs
# Required-Stop: $syslog $remote_fs
# Should-Start: $local_fs
# Should-Stop: $local_fs
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: juggernaut2
# Description: juggernaut2
### END INIT INFO

echo "Run juggernaut"


PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/usr/local/bin/juggernaut
NAME=Juggernaut2 
DESC=Juggernaut2
PIDFILE=/var/run/juggernaut.pid
REDISTOGO_URL='http://brian:123@ec2-50-18-101-127.us-west-1.compute.amazonaws.com:6379'

if test -x $DAEMON 
then
	echo "DAEMON $DAEMON is okay"
else
	echo "We cannot run node as a daemon on OS X, Just run 'juggernaut' in a dedicated console"
	exit 1
fi

test -x $DAEMON || exit 0

set -e

case "$1" in
  start)
      	echo -n "Starting $DESC: "	
	touch $PIDFILE
	#chown juggernaut:juggernaut $PIDFILE
	if start-stop-daemon --start --quiet --umask 007 --pidfile $PIDFILE --chuid juggernaut:juggernaut --exec $DAEMON 
	then
		echo "$NAME."
	else
		echo "failed"
	fi
	;;
  stop)
	echo -n "Stopping $DESC: "
	if start-stop-daemon --stop --retry 10 --quiet --oknodo --pidfile $PIDFILE --exec $DAEMON
	then
		echo "$NAME."
	else
		echo "failed"
	fi
	rm -f $PIDFILE
	;;

  restart|force-reload)
	${0} stop
	${0} start
	;;

  status)
	echo -n "$DESC is "
	if start-stop-daemon --stop --quiet --signal 0 --name ${NAME} --pidfile ${PIDFILE}
	then
		echo "running"
	else
		echo "not running"
	exit 1
	fi
	;;

  *)
	echo "Usage: /etc/init.d/$NAME {start|stop|restart|force-reload}" >&2
	exit 1
	;;
esac

exit 0