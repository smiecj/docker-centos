#!/bin/bash

nohup {kafka_home}/bin/kafka-server-start.sh {kafka_home}/config/server.properties > /dev/null 2>&1 &
