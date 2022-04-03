#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ./env_hive.sh

jps -ml | grep "$hive_module_home" | awk '{print $1}' | xargs --no-run-if-empty kill -9

popd