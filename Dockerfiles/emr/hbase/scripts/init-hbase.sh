#!/bin/bash

pushd {hbase_module_home}/conf

cp hbase-site-template.xml hbase-site.xml

sed -i "s/{HBASE_MASTER_PORT}/${HBASE_MASTER_PORT}/g" hbase-site.xml
sed -i "s/{HBASE_MASTER_INFO_PORT}/${HBASE_MASTER_INFO_PORT}/g" hbase-site.xml
sed -i "s/{HBASE_REGION_SERVER_PORT}/${HBASE_REGION_SERVER_PORT}/g" hbase-site.xml
sed -i "s/{HBASE_REGION_SERVER_INFO_PORT}/${HBASE_REGION_SERVER_INFO_PORT}/g" hbase-site.xml
sed -i "s/{HBASE_THRIFT_PORT}/${HBASE_THRIFT_PORT}/g" hbase-site.xml

popd
