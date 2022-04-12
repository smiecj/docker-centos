#!/bin/bash
set -euxo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ./common.sh
. ./env_zookeeper.sh

# zk config
deploy_mode="singleton"
port=2181
if [ $# -eq 2 ]; then
    deploy_mode=$1
    port=$2
fi

# download zk source code and compile
curl -LO $zookeeper_source_url
tar -xzvf $zookeeper_source_pkg
rm -f $zookeeper_source_pkg

pushd $zookeeper_source_folder

mvn clean install -DskipTests
mkdir -p $zookeeper_module_home

mv zookeeper-assembly/target/$zookeeper_pkg $zookeeper_module_home/

popd
rm -rf $zookeeper_source_folder

pushd $zookeeper_module_home
tar -xzvf $zookeeper_pkg
rm -f $zookeeper_pkg
pushd $zookeeper_folder

# todo: init zookeeper config

popd

# clean java dependency download path

#mvn dependency:purge-local-repository -DreResolve=false
rm -rf $java_repo_home/*

# todo: set zookeeper service with start and stop script