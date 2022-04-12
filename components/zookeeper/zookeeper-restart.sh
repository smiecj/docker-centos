#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ./env_zookeeper.sh

sh zookeeper-stop.sh

nohup $zookeeper_pkg_home/bin/zkServer.sh start > $zookeeper_log_path 2>&1 &

popd