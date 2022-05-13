#!/bin/bash
cd {prometheus_module_home}
sed -i "s/alertmanager:.*/alertmanager:$ALERTMANAGER_PORT/g" prometheus.yml
sed -i "s/targets: \[.*/targets: \[\"localhost:$PROMETHEUS_PORT\"\]/g" prometheus.yml