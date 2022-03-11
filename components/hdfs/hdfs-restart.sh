#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ./env_hdfs.sh

sh hdfs-stop.sh

nohup $hdfs_module_home/sbin/start-dfs.sh > /dev/null 2>&1 &
nohup $hdfs_module_home/sbin/start-yarn.sh > /dev/null 2>&1 &

popd