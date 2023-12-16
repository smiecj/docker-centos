#!/bin/bash

pushd {spark_module_home}

./sbin/stop-history-server.sh

popd

sleep 1