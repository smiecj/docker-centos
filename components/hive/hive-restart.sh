#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ./env_hive.sh

sh hive-stop.sh

nohup $hive_module_home/bin/hive --service metastore > $hive_metastore_log_path 2>&1 &

sleep 2

nohup $hive_module_home/bin/hive --service hiveserver2 --hiveconf hive.root.logger=INFO,console > $hive_hiveserver2_log_path 2>&1 &

popd