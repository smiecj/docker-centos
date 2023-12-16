#!/bin/bash

pushd {spark_module_home}

./sbin/start-master.sh

./sbin/start-slave.sh spark://${SPARK_MASTER_HOST}:${SPARK_MASTER_RPC_PORT}

if [ "${SPARK_HISTORY_ENABLE}" == "true" ]; then
    ./sbin/start-history-server.sh
fi

popd