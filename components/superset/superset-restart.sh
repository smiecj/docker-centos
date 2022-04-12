#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ./env_superset.sh

sh superset-stop.sh

nohup superset run -h 0.0.0.0 -p $port --with-threads --reload --debugger > $superset_log_path 2>&1 &

popd