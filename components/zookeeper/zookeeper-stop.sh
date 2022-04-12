#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ./env_zookeeper.sh

ps -ef | grep "$zookeeper_pkg_home" | grep -v grep | awk '{print $2}' | xargs --no-run-if-empty kill -9

popd