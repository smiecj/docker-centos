#!/bin/bash

# local ip

local_ip=`ifconfig eth0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'`
export PRIORITY_NETWORKS="`echo ${local_ip} | sed 's#\.[[:digit:]]$#.0#g'`/24"

# init config
pushd {doris_be_module_home}/conf

## be.conf
cp be.conf_example be.conf

mkdir -p ${BE_STORAGE_PATH}

popd

pushd {doris_fe_module_home}/conf

## fe.conf
cp fe.conf_example fe.conf

mkdir -p ${FE_META_DIR}

popd

# replace

env_keys=`printenv | sed "s#=.*##g"`

for current_env_key in ${env_keys[@]}
do
    sed -i "s#{${current_env_key}}#${!current_env_key}#g" {doris_fe_module_home}/conf/fe.conf
    sed -i "s#{${current_env_key}}#${!current_env_key}#g" {doris_be_module_home}/conf/be.conf
done

## after connect: init doris account

nohup dorisaccountinit > /tmp/dorisaccountinit.log 2>&1 &