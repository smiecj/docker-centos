#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ./common.sh
. ./env_hudi.sh

## install java
sh ./init-system-java.sh
source /etc/profile

set -euxo pipefail

## compile hudi
rm -rf $hudi_module_home
mkdir -p $hudi_module_home
pushd $hudi_module_home

curl -LO $hudi_source_code_url
tar -xzvf $hudi_source_code_url
rm -f $hudi_source_pkg

pushd $hudi_module
mvn clean package -DskipTests
mv packaging ../
popd
rm -rf $hudi_module

## spark download

curl -LO $spark_pkg_url
tar -xvf $spark_pkg
rm -f $spark_pkg

### add and enable hudi service
mkdir -p $hudi_scripts_home
cp -f $home_path/env_hudi.sh $hudi_scripts_home
cp -f $home_path/../components/hudi/hudi-restart.sh $hudi_scripts_home
cp -f $home_path/../components/hudi/hudi-stop.sh $hudi_scripts_home
chmod -R 744 $hudi_scripts_home

add_systemd_service hudi $PATH "" $hudi_scripts_home/hudi-restart.sh $hudi_scripts_home/hudi-stop.sh "true"

### add log rotate
# add_logrorate_task $hudi_log_path hudi

popd
