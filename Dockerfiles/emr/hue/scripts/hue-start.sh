#!/bin/bash

source /etc/profile

## init db
huesyncdb

## start
mkdir -p /var/run/hue && chmod -R 777 /var/run/hue
{hue_install_path}/build/env/bin/supervisor -p /var/run/hue/supervisor.pid -l /var/log/hue -d
