#!/bin/bash

ps -ef | grep "vue-cli-service serve" | grep -v grep | awk '{print $2}' | xargs --no-run-if-empty kill -9
sleep 3
