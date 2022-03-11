#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ./env_hdfs.sh

jps -ml | grep -v "sun.tools.jps.Jps" | awk '{print $1}' | xargs --no-run-if-empty kill -9

popd