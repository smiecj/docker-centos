#!/bin/bash
#set -euxo pipefail

# install centos develop system

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ./env_system.sh

## judge system architecture and decide some variable value
system_arch=`uname -p`

## go install
sh ./init-system-golang.sh

## java install (openjdk)
sh ./init-system-java.sh

## npm install
sh ./init-system-node.sh

## python install
sh ./init-system-python.sh

### check all develop environment have installed
source /etc/profile && go version && java -version && npm -v && node -v && $CONDA_HOME/envs/py3/bin/python3 -V

## vim support utf-8
echo "set encoding=utf-8 fileencodings=ucs-bom,utf-8,cp936" >> ~/.vimrc

## ulimit: max open files
echo -e "* soft nofile 100001\n* hard nofile 100002" >> /etc/security/limits.conf

## clean history
history -c

## timezone
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

popd