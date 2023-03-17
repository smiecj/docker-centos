#!/bin/bash

ps -ef | grep 'prefect orion start' | grep -v grep | awk '{print $2}' | xargs --no-run-if-empty kill -9

ps -ef | grep 'prefect agent start' | grep -v grep | awk '{print $2}' | xargs --no-run-if-empty kill -9

ps -ef | grep 'prefect.orion.api.server' | grep -v grep | awk '{print $2}' | xargs --no-run-if-empty kill -9

sleep 3