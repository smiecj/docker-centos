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
echo "export LC_CTYPE=en_US.UTF-8" >> ~/.bashrc
echo "export LC_ALL=en_US.UTF-8" >> ~/.bashrc
echo "export BASHRCSOURCED=Y" >> ~/.bashrc
echo "export HISTCONTROL=ignoreboth" >> ~/.bashrc

## locale
localedef -v -c -i en_US -f UTF-8 en_US.UTF-8
source /etc/profile

## set login password
echo root:$root_pwd | chpasswd

#exec /usr/sbin/init
