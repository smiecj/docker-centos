#!/bin/bash
#set -euxo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

## install python
sh ./init-system-python.sh
source /etc/profile

## install jupyter
jupyter_home=/home/modules/jupyter
rm -rf $jupyter_home
mkdir -p $jupyter_home
pushd $jupyter_home

curl -LO https://github.com/smiecj/python-tools/archive/refs/heads/main.zip
unzip main.zip
pushd python-tools-main
make install_jupyter
popd

rm -f main.zip
rm -rf python-tools-main
popd

## set jupyter auto start
systemctl enable jupyter

popd