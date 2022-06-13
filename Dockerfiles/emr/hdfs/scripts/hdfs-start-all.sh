#!/bin/bash

# sleep sometime to ensure sshd has started
sleep 3
source /etc/profile && nohup {hdfs_module_home}/sbin/start-all.sh > /tmp/test.log 2>&1 &
