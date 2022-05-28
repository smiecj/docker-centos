#!/bin/bash

# singleton

## server properties
sed -i "s#zookeeper.connect=.*#zookeeper.connect=${zookeeper_server}##g" {kafka_home}/config/server.properties
### default listener: bind local ip
local_ip=`ifconfig | grep -A 1 eth0 | sed -n '2p' | awk -F' {1,}' '{print $3}'`
sed -i "s/#listeners=/listeners=/g" {kafka_home}/config/server.properties
sed -i "s#listeners=.*#listeners=PLAINTEXT://${local_ip}:${broker_port}#g" {kafka_home}/config/server.properties
#listeners=PLAINTEXT://:9092

## producer properties

## consumer properties

# todo: cluster