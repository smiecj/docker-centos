#!/bin/bash

ps -ef | grep '{code_server_module_home}/lib/node' | grep -v grep | awk '{print $2}' | xargs --no-run-if-empty kill -9

sleep 3