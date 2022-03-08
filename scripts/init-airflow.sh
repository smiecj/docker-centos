#!/bin/bash
#set -euxo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

## install python
sh ./init-system-python.sh
source /etc/profile

## install airflow
airflow_home=/home/modules/airflow
rm -rf $airflow_home
mkdir -p $airflow_home
pushd $airflow_home

curl -LO https://github.com/smiecj/python-tools/archive/refs/heads/main.zip
unzip main.zip
pushd python-tools-main
make install_airflow
popd

rm -f main.zip
rm -rf python-tools-main

popd