#!/bin/bash

ps -ef | grep "{alertmanager_module_home}/alertmanager" | grep -v grep | awk '{print $2}' | xargs --no-run-if-empty kill -9
sleep 3
