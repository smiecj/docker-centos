#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ./env_redis.sh

nohup $redis_bin_path/redis-server $redis_module_path/redis.conf > /dev/null 2>&1 &
