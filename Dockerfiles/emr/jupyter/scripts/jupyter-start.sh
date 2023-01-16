#!/bin/bash

source /etc/profile

nohup configurable-http-proxy --ip 0.0.0.0 --port ${proxy_port} --api-ip 127.0.0.1 --api-port ${api_port} --error-target $proxy_address/hub/error > /dev/null 2>&1 &

nohup jupyterhub --config {jupyter_config_home}/jupyterhub_config.py >> {jupyterhub_log} 2>&1 &
