#!/bin/bash

# jps -ml | grep "com.ucar.datalink.manager.core.boot.ManagerBootStrap" | awk '{print $1}' | xargs --no-run-if-empty kill -9

pushd {datalink_worker_home}
./bin/stop.sh
popd