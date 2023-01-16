#!/bin/bash

pushd {es_module_home}/config

cp elasticsearch_template.yml elasticsearch.yml
cp jvm_template.options jvm.options

sed -i "s/{ES_PORT}/${ES_PORT}/g" elasticsearch.yml
sed -i "s/{XMX}/${XMX}/g" jvm.options
sed -i "s/{XMS}/${XMS}/g" jvm.options

popd
