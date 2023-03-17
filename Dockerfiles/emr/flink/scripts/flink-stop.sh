#!/bin/bash

pushd {flink_module_home}

./bin/stop-cluster.sh

popd

sleep 3