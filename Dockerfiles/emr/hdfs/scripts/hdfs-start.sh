#!/bin/bash

# sleep sometime to ensure sshd has started
sleep 3
nohup {hdfs_module_home}/sbin/start-dfs.sh > {dfs_log_path} 2>&1 &
nohup {hdfs_module_home}/sbin/start-yarn.sh > {yarn_log_path} 2>&1 &
