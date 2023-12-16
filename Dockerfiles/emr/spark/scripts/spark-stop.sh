#!/bin/bash

pushd {spark_module_home}

./sbin/stop-slave.sh

./sbin/stop-master.sh

if [ "${SPARK_HISTORY_ENABLE}" == "true" ]; then
    ./sbin/stop-history-server.sh
fi

popd

sleep 3