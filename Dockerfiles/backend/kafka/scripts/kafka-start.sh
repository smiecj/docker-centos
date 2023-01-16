#!/bin/bash

nohup {kafka_module_home}/bin/kafka-server-start.sh {kafka_module_home}/config/server.properties > /dev/null 2>&1 &
