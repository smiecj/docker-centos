#!/bin/bash

pushd {prometheus_module_home}

cp prometheus_template.yml prometheus.yml

sed -i "s/{ALERTMANAGER_HOST}/${ALERTMANAGER_HOST}/g" prometheus.yml
sed -i "s/{ALERTMANAGER_PORT}/${ALERTMANAGER_PORT}/g" prometheus.yml

sed -i "s/{PROMETHEUS_HOST}/${PROMETHEUS_HOST}/g" prometheus.yml
sed -i "s/{PROMETHEUS_PORT}/${PROMETHEUS_PORT}/g" prometheus.yml

sed -i "s/{PUSHGATEWAY_HOST}/${PUSHGATEWAY_HOST}/g" prometheus.yml
sed -i "s/{PUSHGATEWAY_PORT}/${PUSHGATEWAY_PORT}/g" prometheus.yml

sed -i "s/{NODE_EXPORTER_HOST}/${NODE_EXPORTER_HOST}/g" prometheus.yml
sed -i "s/{NODE_EXPORTER_PORT}/${NODE_EXPORTER_PORT}/g" prometheus.yml

popd