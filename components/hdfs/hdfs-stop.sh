#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ./env_hdfs.sh

jps -ml | grep "org.apache.hadoop.hdfs" | awk '{print $1}' | xargs --no-run-if-empty kill -9
jps -ml | grep "org.apache.hadoop.yarn" | awk '{print $1}' | xargs --no-run-if-empty kill -9

popd