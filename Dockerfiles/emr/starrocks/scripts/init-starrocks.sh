#!/bin/bash

# init config
pushd {starrocks_be_module_home}/conf

## be.conf
cp be.conf_example be.conf
sed -i "s#{BE_PORT}#${BE_PORT}#g" be.conf
sed -i "s#{BE_HEARTBEAT_PORT}#${BE_HEARTBEAT_PORT}#g" be.conf
sed -i "s#{BE_BRPC_PORT}#${BE_BRPC_PORT}#g" be.conf
sed -i "s#{BE_HTTP_PORT}#${BE_HTTP_PORT}#g" be.conf
sed -i "s#{BE_STORAGE_PATH}#${BE_STORAGE_PATH}#g" be.conf

mkdir -p ${BE_STORAGE_PATH}

popd

pushd {starrocks_fe_module_home}/conf

## fe.conf
cp fe.conf_example fe.conf
sed -i "s#{FE_HTTP_PORT}#${FE_HTTP_PORT}#g" fe.conf
sed -i "s#{FE_RPC_PORT}#${FE_RPC_PORT}#g" fe.conf
sed -i "s#{FE_QUERY_PORT}#${FE_QUERY_PORT}#g" fe.conf
sed -i "s#{FE_EDIT_PORT}#${FE_EDIT_PORT}#g" fe.conf
sed -i "s#{FE_META_DIR}#${FE_META_DIR}#g" fe.conf

mkdir -p ${FE_META_DIR}

popd

## after connect: init starrocks account

nohup starrocksaccountinit > /tmp/starrocksaccountinit.log 2>&1 &