#!/bin/bash

if [[ "cluster" == "${MODE}" ]]; then
    # cluster
    echo "start kafka cluster, node num: ${ID}"
    sed -i "s#broker.id=.*#broker.id=${ID}##g" {kafka_module_home}/config/server.properties
elif [[ "singleton" == "${MODE}" ]]; then
    # singleton
    echo "start kafka singleton"
else
    exit 1
fi

# common config
## server properties
sed -i "s#zookeeper.connect=.*#zookeeper.connect=${zookeeper_server}##g" {kafka_module_home}/config/server.properties
### default listener: bind local ip
local_ip=`ifconfig | grep -A 1 eth0 | sed -n '2p' | awk -F' {1,}' '{print $3}'`
sed -i "s/#listeners=/listeners=/g" {kafka_module_home}/config/server.properties
sed -i "s#listeners=.*#listeners=PLAINTEXT://${local_ip}:${broker_port}#g" {kafka_module_home}/config/server.properties

# jmx
sed -i "s/export JMX_PORT=.*/export JMX_PORT=${jmx_port}/g" {kafka_module_home}/bin/kafka-server-start.sh