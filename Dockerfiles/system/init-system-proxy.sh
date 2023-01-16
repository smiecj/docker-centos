#!/bin/bash

current_proxy=`cat /etc/profile | grep http_proxy`
if [ -n "${current_proxy}" ]; then
    exit 0
fi

proxy_host_list=("host.docker.internal" "172.17.0.1")
proxy_port_list=("7890" "8118")

if [[ "${HAS_PROXY}" == "true" ]]; then
    if [ -n "${http_proxy}" ]; then
        : # do nothing
    elif [ -n "${HTTP_PROXY}" ]; then
        echo "export http_proxy=${HTTP_PROXY}" >> /etc/profile
        echo "export https_proxy=${HTTPS_PROXY}" >> /etc/profile
    else
        for index in "${!proxy_host_list[@]}"
        do
            proxy_host=${proxy_host_list[$index]}
            proxy_port=${proxy_port_list[$index]}
            telnet_output=`timeout 1 telnet $proxy_host $proxy_port 2>&1` || true
            telnet_refused_msg=`echo $telnet_output | grep "Connection refused" || true`
            telnet_host_unknown_msg=`echo $telnet_output | grep "Unknown host" || true`
            if [ -n "$telnet_output" ] && [ -z "$telnet_refused_msg" ] && [ -z "$telnet_host_unknown_msg" ]; then
                echo "export http_proxy=http://$proxy_host:$proxy_port" >> /etc/profile
                echo "export https_proxy=http://$proxy_host:$proxy_port" >> /etc/profile
                break
            fi
        done
    fi
    
    echo "export no_proxy=127.0.0.1,localhost" >> /etc/profile
fi