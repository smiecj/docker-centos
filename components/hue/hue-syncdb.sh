#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ./env_hue.sh

$hue_install_path/build/env/bin/hue syncdb --noinput
$hue_install_path/build/env/bin/hue migrate