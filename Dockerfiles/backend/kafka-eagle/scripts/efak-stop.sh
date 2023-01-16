#!/bin/bash

jps -ml | grep "org.apache.catalina.startup.KafkaEagle" | awk '{print $1}' | xargs --no-run-if-empty kill -9
jps -ml | grep "org.smartloli.kafka.eagle.core.task.rpc.server.WorkNodeServer" | awk '{print $1}' | xargs --no-run-if-empty kill -9

# pushd {kafka_eagle_module_home}
# ./bin/ke.sh cluster stop
# popd

sleep 3