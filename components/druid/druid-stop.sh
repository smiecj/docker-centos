#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ./env_druid.sh

ps -ef | grep "$druid_module_home" | grep -v grep | awk '{print $2}' | xargs --no-run-if-empty kill -9