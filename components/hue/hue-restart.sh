#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ./env_hue.sh

ps -ef | grep "$hue_install_path" | grep -v grep | awk '{print $2}' | xargs --no-run-if-empty kill -9

source /etc/profile
mkdir -p /var/run/hue && chmod -R 777 /var/run/hue
$hue_install_path/build/env/bin/supervisor -p /var/run/hue/supervisor.pid -l /var/log/hue -d