#!/bin/bash
set -euxo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ./common.sh
. ./env_system.sh
. ./env_zookeeper.sh

# zk config
deploy_mode="singleton"
zk_port=2181
if [ $# -eq 2 ]; then
    deploy_mode=$1
    zk_port=$2
fi

# download zk source code and compile
curl -LO $zookeeper_source_url
tar -xzvf $zookeeper_source_pkg
rm -f $zookeeper_source_pkg

pushd $zookeeper_source_folder

mvn clean install -DskipTests
rm -rf $zookeeper_module_home
mkdir -p $zookeeper_module_home

mv zookeeper-assembly/target/$zookeeper_pkg $zookeeper_module_home/

popd
rm -rf $zookeeper_source_folder

pushd $zookeeper_module_home
tar -xzvf $zookeeper_pkg
rm -f $zookeeper_pkg
pushd $zookeeper_folder

# init zookeeper config
zk_config_file=./conf/zoo.cfg
if [[ "singleton" == "$deploy_mode" ]]; then
    cp -f $home_path/../components/zookeeper/zoo_singleton.cfg $zk_config_file
fi
## todo: cluster zk config (port, hostname)
mkdir -p $zookeeper_data_home

zookeeper_data_home_replace_str=$(echo "$zookeeper_data_home" | sed 's/\//\\\//g')
sed -i "s/{data_dir}/$zookeeper_data_home_replace_str/g" $zk_config_file
sed -i "s/{port}/$zk_port/g" $zk_config_file

popd

# clean java dependency download path

#mvn dependency:purge-local-repository -DreResolve=false
rm -rf $java_repo_home/maven/*

# set zookeeper service with start and stop script
mkdir -p $zookeeper_scripts_home
cp -f $home_path/env_zookeeper.sh $zookeeper_scripts_home
cp -f $home_path/../components/zookeeper/zookeeper-restart.sh $zookeeper_scripts_home
cp -f $home_path/../components/zookeeper/zookeeper-stop.sh $zookeeper_scripts_home
chmod -R 744 $zookeeper_scripts_home

add_systemd_service zookeeper $PATH "" $zookeeper_scripts_home/zookeeper-restart.sh $zookeeper_scripts_home/zookeeper-stop.sh "true"

# copy zk connect script to bin path
cp -f $home_path/env_zookeeper.sh $user_local_bin_home
cp -f $home_path/../components/zookeeper/zkconnect.sh $user_local_bin_home/zkconnect
chmod +x $user_local_bin_home/zkconnect
sed -i "s/{port}/$zk_port/g" $user_local_bin_home/zkconnect

popd