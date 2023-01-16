#!/bin/bash

pushd {kibana_module_home}/config

cp kibana_template.yml kibana.yml

sed -i "s/{KIBANA_PORT}/${KIBANA_PORT}/g" kibana.yml
sed -i "s#{ES_ADDRESS}#${ES_ADDRESS}#g" kibana.yml

popd
