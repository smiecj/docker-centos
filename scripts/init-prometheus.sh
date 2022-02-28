#!/bin/bash
set -euxo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

## env init
. ./env_prometheus.sh

## prometheus
rm -rf $prometheus_module_home
mkdir -p $prometheus_module_home
pushd $prometheus_module_home
curl -LO $prometheus_download_url
tar -xzvf $prometheus_pkg
rm -f $prometheus_pkg

### config
pushd $prometheus_folder
sed -i 's/alertmanager:.*/alertmanager:/g' prometheus.yml
sed -i "s/targets: \[.*/targets: \[\"localhost:$prometheus_port\"\]/g" prometheus.yml
popd

## alertmanager
curl -LO $alertmanager_download_url
tar -xzvf $alertmanager_pkg
rm -f $alertmanager_pkg

### config
pushd $alertmanager_folder
popd

## restart on reboot
echo "@reboot nohup $prometheus_full_path/prometheus --web.enable-lifecycle --config.file=$prometheus_full_path/prometheus.yml --web.listen-address=:$prometheus_port >> $prometheus_full_path/prometheus.log 2>&1 &" >> /var/spool/cron/root
echo "@reboot nohup $alertmanager_full_path/alertmanager --config.file=$alertmanager_full_path/alertmanager.yml --storage.path=$alertmanager_full_path/data --web.listen-address=localhost:$alertmanager_port >> $alertmanager_full_path/alertmanager.log 2>&1 &" >> /var/spool/cron/root

### todo: support webhook

popd

popd