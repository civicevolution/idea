#!/usr/bin/env bash                                                                                                                                                  

if [ $# -lt 1 ] ; then
    echo "Usage:   " $0 " <start | stop> "
    exit 1
fi

action=$1

script_location=$(cd ${0%/*} && pwd -P)
cd $script_location/..
rails_root=`pwd`

if [ -f "/etc/profile" ]; then
  . /etc/profile
fi

echo $script_location
echo $action

logfile=$rails_root/log/notification.rb.log
echo "-----------------------------------------------" >> $logfile 2>&1
echo "Running bundle exec lib/daemons/notification_ctl $action" >> $logfile 2>&1
echo `date` >> $logfile 2>&1
echo `pwd` >> $logfile 2>&1
#echo `env` >> $logfile 2>&1

bundle exec lib/daemons/notification_ctl $action >> $logfile 2>&1
