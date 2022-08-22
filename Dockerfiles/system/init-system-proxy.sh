#!/bin/bash

current_proxy=`cat /etc/profile | grep http_proxy`
if [[ "$current_proxy" != "" ]]; then
    exit 0
fi

default_http_proxy=http://host.docker.internal:7890
default_https_proxy=https://host.docker.internal:7890

if [[ "${HAS_PROXY}" == "true" ]]; then
    # set default proxy or user proxy
    http_proxy=default_http_proxy
    https_proxy=default_https_proxy
    if [[ "${HTTP_PROXY}" != "" ]]; then
        echo "export http_proxy=${HTTP_PROXY}" >> /etc/profile
        echo "export https_proxy=${HTTPS_PROXY}" >> /etc/profile
    else
        echo "export http_proxy=${default_http_proxy}" >> /etc/profile
        echo "export https_proxy=${default_https_proxy}" >> /etc/profile
    fi
fi