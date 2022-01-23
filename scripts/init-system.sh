#!/bin/bash
#set -euxo pipefail

. ./common.sh

## install centos basic tools
install_basic_tools

## bashrc
sed -i "s/alias cp/#alias cp/g" ~/.bashrc
sed -i "s/alias mv/#alias mv/g" ~/.bashrc
echo "alias ll='ls -l'" >> ~/.bashrc
echo "alias rm='rm -f'" >> ~/.bashrc

## set login password
#### default password: root!centos123
root_pwd="root!centos123"
if [ "" != "$ROOT_PWD" ]; then
    root_pwd=$ROOT_PWD
fi

echo root:$root_pwd | chpasswd

#exec /usr/sbin/init
