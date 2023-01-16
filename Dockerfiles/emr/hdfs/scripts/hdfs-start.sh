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

# check localhost and 0.0.0.0 has connect (add key)
# ssh -o StrictHostKeyChecking=no localhost > /dev/null 2>&1 &
# ssh -o StrictHostKeyChecking=no 0.0.0.0 > /dev/null 2>&1 &

nohup {hdfs_module_home}/sbin/start-dfs.sh > {dfs_log_path} 2>&1 &
nohup {hdfs_module_home}/sbin/start-yarn.sh > {yarn_log_path} 2>&1 &
