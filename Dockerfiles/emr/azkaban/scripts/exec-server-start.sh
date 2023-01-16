#!/bin/bash

pushd {azkaban_exec_server_home}
{azkaban_exec_server_home}/bin/start-exec.sh
popd

## activate

while :
do
    connect_exec_server_cmd=`curl http://localhost:${EXEC_SERVER_PORT}/executor?action=getStatus`
    connect_exec_server_ret=$?

    if [[ "0" == "$connect_exec_server_ret" ]]; then
        echo "executor has started"
        curl http://localhost:${EXEC_SERVER_PORT}/executor?action=activate
        exit 0
    else
        echo "executor has not started"
        sleep 1
    fi
done
