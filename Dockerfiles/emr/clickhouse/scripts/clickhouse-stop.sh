#!/bin/bash

ps -ef | grep "/usr/bin/clickhouse-server" | grep -v grep | awk '{print $2}' | xargs --no-run-if-empty kill -9
ps -ef | grep "clickhouse-watchdog" | grep -v grep | awk '{print $2}' | xargs --no-run-if-empty kill -9
sleep 3