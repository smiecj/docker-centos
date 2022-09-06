#!/bin/bash

ps -ef | grep "{grafana_module_home}/bin/grafana-server" | grep -v grep | awk '{print $2}' | xargs --no-run-if-empty kill -9
sleep 3
