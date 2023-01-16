#!/bin/bash

nohup /usr/bin/clickhouse-server --config=/etc/clickhouse-server/config.xml --pid-file=/run/clickhouse-server/clickhouse-server.pid > /dev/null 2>&1 &