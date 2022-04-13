#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ./env_redis.sh

ps -ef | grep "$redis_module_path" | grep -v grep | grep -v "redis-stop" | grep -v "systemctl " | awk '{print $2}' | xargs --no-run-if-empty kill -9
sleep 3

popd