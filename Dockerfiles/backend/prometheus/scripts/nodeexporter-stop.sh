#!/bin/bash

ps -ef | grep "{node_exporter_home}/node_exporter" | grep -v grep | awk '{print $2}' | xargs --no-run-if-empty kill -9
sleep 3
