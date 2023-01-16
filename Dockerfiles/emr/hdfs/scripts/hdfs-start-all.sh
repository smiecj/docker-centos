#!/bin/bash

# sleep sometime to ensure sshd has started
while :
do
    sshd_process_exists=`ps -ef | grep "/usr/sbin/sshd" |  grep -v grep | wc -l`
    if [[ "0" == "$sshd_process_exists" ]]; then
        echo "sshd process has not start, will continuous wait"
        sleep 1
    else
        break
    fi
done

source /etc/profile && nohup {hdfs_module_home}/sbin/start-all.sh > /tmp/test.log 2>&1 &
