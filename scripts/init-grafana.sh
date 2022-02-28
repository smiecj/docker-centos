#!/bin/bash
set -euxo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

## env init
. ./env_grafana.sh

## grafana
rm -rf $grafana_module_home
mkdir -p $grafana_module_home
pushd $grafana_module_home

### download
curl -LO $grafana_download_url
tar -xzvf $grafana_pkg
rm -f $grafana_pkg
pushd $grafana_folder

### config
pushd conf
cp defaults.ini $grafana_config_file
sed -i "s/http_port =.*/http_port = $grafana_port/g" $grafana_config_file
popd

popd

popd

## restart on reboot

echo "@reboot nohup $grafana_full_path/bin/grafana-server --homepath $grafana_full_path --config $grafana_full_path/conf/$grafana_config_file >> $grafana_full_path/grafana.log 2>&1 &" >> /var/spool/cron/root

popd