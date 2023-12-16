#!/bin/bash

pushd {spark_module_home}

./sbin/start-all.sh

if [ "${SPARK_HISTORY_ENABLE}" == "true" ]; then
    ./sbin/start-history-server.sh
fi

popd