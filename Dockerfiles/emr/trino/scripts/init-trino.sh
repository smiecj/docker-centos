#!/bin/bash

# init config
pushd {trino_module_home}
host_name=`hostname`

## config.properties
cp etc/config.properties_template etc/config.properties
sed -i "s#{PORT}#${PORT}#g" etc/config.properties
sed -i "s#{hostname}#${host_name}#g" etc/config.properties

## node.properties
mkdir -p ${DATA_DIR}
cp etc/node.properties_template etc/node.properties
sed -i "s#{hostname}#${host_name}#g" etc/node.properties
sed -i "s#{DATA_DIR}#${DATA_DIR}#g" etc/node.properties

## jvm.config
cp etc/jvm.config_template etc/jvm.config
sed -i "s#{XMX}#${XMX}#g" etc/jvm.config

## log.properties
cp etc/log.properties_template etc/log.properties

## hive
cp etc/catalog/hive.properties_template etc/catalog/hive.properties
sed -i "s#{HIVE_METASTORE_URL}#${HIVE_METASTORE_URL}#g" etc/catalog/hive.properties
sed -i "s#{HADOOP_CONF_DIR}#${HADOOP_CONF_DIR}#g" etc/catalog/hive.properties

popd