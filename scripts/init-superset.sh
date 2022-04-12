#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ./common.sh
. ./env_superset.sh

## install python
sh ./init-system-python.sh
source /etc/profile

set -euxo pipefail

## compile superset
mkdir -p $superset_module_home
### later: there is some problem install superset from source code, try again later

## pip install superset
pip3 install apache-superset==$superset_version
pip3 install markupsafe==2.0.1
pip3 install Pillow==9.1.0

## superset config
# init db
superset db upgrade

# Create an admin user in your metadata database (use `admin` as username to be able to load the examples)
echo """
# superset
export FLASK_APP=supersets""" >> /etc/profile
export FLASK_APP=supersets

superset fab create-admin --username $superset_username --firstname $superset_first_name --lastname $superset_last_name --email $superset_email --password $superset_password

# Load some data to play with
superset load_examples

# Create default roles and permissions
superset init

### add and enable superset service
mkdir -p $superset_scripts_home
cp -f $home_path/env_superset.sh $superset_scripts_home
cp -f $home_path/../components/superset/superset-restart.sh $superset_scripts_home
cp -f $home_path/../components/superset/superset-stop.sh $superset_scripts_home
chmod -R 744 $superset_scripts_home

add_systemd_service superset $PATH "" $superset_scripts_home/superset-restart.sh $superset_scripts_home/superset-stop.sh "true"

### add log rotate
add_logrorate_task $superset_log_path superset

popd
