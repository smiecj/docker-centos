#!/bin/bash

ps -ef | grep '/usr/bin/python3' | grep "jupyter" | grep -v grep | awk '{print $2}' | xargs --no-run-if-empty kill -9

ps -ef | grep 'configurable-http-proxy' | grep -v grep | awk '{print $2}' | xargs --no-run-if-empty kill -9

sleep 3