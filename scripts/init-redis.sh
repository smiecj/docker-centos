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
rm -f $redis_pkg
pushd $redis_folder

### compile
make

### copy bin and config file

cp src/redis-cli $redis_bin_path
cp src/redis-server $redis_bin_path
cp src/redis-sentinel $redis_bin_path
cp src/redis-benchmark $redis_bin_path
cp redis.conf $redis_module_path

popd

### init config
sed -i "s/^port 6379/port $redis_port/g" redis.conf
redis_log_replace_path=$(echo "$redis_log_path" | sed 's/\//\\\//g')
sed -i "s/logfile \"\"/logfile $redis_log_replace_path/g" redis.conf

#### set default bind (allow all host) and protected mode (no)
sed -i "s/^protected-mode .*/protected-mode no/g" redis.conf
sed -i "s/^bind .*/bind * -::*/g" redis.conf

### remove source code
rm -rf $redis_folder

popd

### profile
echo """
export PATH=\$PATH:$redis_bin_path
""" >> /etc/profile

### start and stop script
mkdir -p $redis_scripts_path
cp -f ./env_redis.sh $redis_scripts_path
cp -f $home_path/../components/redis/redis-restart.sh $redis_scripts_path
cp -f $home_path/../components/redis/redis-stop.sh $redis_scripts_path
chmod -R 755 $redis_scripts_path

### add and enable redis service
add_systemd_service redis $PATH "" $redis_scripts_path/redis-restart.sh $redis_scripts_path/redis-stop.sh "true"

add_logrorate_task $redis_log_path redis

popd