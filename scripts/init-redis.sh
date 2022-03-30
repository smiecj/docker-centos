#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

## env init
. ./common.sh

. ./env_redis.sh

source /etc/profile

## redis
### download source code
rm -rf $redis_module_path
mkdir -p $redis_module_path
pushd $redis_module_path

curl -LO $redis_download_url
tar -xzvf $redis_pkg
pushd $redis_folder

### compile
make

### copy bin and config file

cp src/redis-cli ../
cp src/redis-server ../
cp src/redis-sentinel ../
cp src/redis-benchmark ../
cp redis.conf ../

popd

### init config
sed -i "s/^port 6379/port $redis_port/g" redis.conf
redis_log_replace_path=$(echo "$redis_log_path" | sed 's/\//\\\//g')
sed -i "s/logfile \"\"/logfile $redis_log_replace_path/g" redis.conf

### remove source code

rm -rf $redis_folder

popd

### start and stop script
mkdir -p $redis_scripts_path
cp -f ./env_redis.sh $redis_scripts_path
cp -f $home_path/../components/redis/redis-restart.sh $redis_scripts_path
cp -f $home_path/../components/redis/redis-stop.sh $redis_scripts_path
chmod -R 755 $redis_scripts_path

### add and enable hdfs service
add_systemd_service redis $PATH "" $redis_scripts_path/redis-restart.sh $redis_scripts_path/redis-stop.sh "true"

add_logrorate_task $redis_log_path redis

popd