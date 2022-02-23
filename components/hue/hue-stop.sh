#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ./env_hue.sh

ps -ef | grep "$hue_install_path" | grep -v grep | awk '{print $2}' | xargs --no-run-if-empty kill -9