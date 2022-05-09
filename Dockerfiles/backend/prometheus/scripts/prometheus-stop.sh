#!/bin/bash

ps -ef | grep "{prometheus_module_home}/prometheus" | grep -v grep | awk '{print $2}' | xargs --no-run-if-empty kill -9
sleep 3
