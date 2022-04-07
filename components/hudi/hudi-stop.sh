#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ./env_hudi.sh

ps -ef | grep "$hudi_module_home" | grep -v grep | awk '{print $2}' | xargs --no-run-if-empty kill -9

popd