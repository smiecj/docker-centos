#!/bin/bash

azkaban_exec_server_pid=`jps -ml | grep azkaban.execapp.AzkabanExecutorServer | sed 's/ .*//g'`
if [ "" != "${azkaban_exec_server_pid}" ]; then
    {azkaban_exec_server_home}/bin/shutdown-exec.sh
fi
