#!/bin/bash
set -euxo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ./env_system.sh

## 设置 docker 镜像内部接口
## 一般在开启代理的时候需要设置
for proxy_host in ${proxy_host_array[@]}
do
    for proxy_port in ${proxy_port_array[@]}
    do
        telnet_output="$({ sleep 1; echo $'\e'; } | telnet $proxy_host $proxy_port 2>&1)" || true 
        telnet_refused_msg=`echo $telnet_output | grep "Connection refused" || true`
        telnet_host_unknown_msg=`echo $telnet_output | grep "Unknown host" || true`
        if [ -z "$telnet_refused_msg" ] && [ -z "$telnet_host_unknown_msg" ]; then
            echo "export http_proxy=http://$proxy_host:$proxy_port" >> /etc/profile
            echo "export https_proxy=http://$proxy_host:$proxy_port" >> /etc/profile
            break
        fi
    done
    current_proxy=`cat /etc/profile | grep http_proxy || true`
    if [ -n "$current_proxy" ]; then
        break
    fi
done
