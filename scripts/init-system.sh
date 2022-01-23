#!/bin/bash
#set -euxo pipefail

# 获取镜像初始化参数
root_pwd="root!centos123"
if [[ $# -gt 0 ]]; then
    root_pwd=$1
fi

. ./common.sh

## install centos basic tools
install_basic_tools

## bashrc
sed -i "s/alias cp/#alias cp/g" ~/.bashrc
sed -i "s/alias mv/#alias mv/g" ~/.bashrc
echo "alias ll='ls -l'" >> ~/.bashrc
echo "alias rm='rm -f'" >> ~/.bashrc

## profile
echo "export LC_CTYPE=en_US.UTF-8" >> /etc/profile
echo "export LC_ALL=en_US.UTF-8" >> /etc/profile
echo "export BASHRCSOURCED=Y" >> /etc/profile

## set login password
echo root:$root_pwd | chpasswd

#exec /usr/sbin/init
