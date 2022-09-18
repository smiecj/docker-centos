#!/bin/bash

nohup {pushgateway_home}/pushgateway --web.listen-address=":${PUSHGATEWAY_PORT}" --web.enable-admin-api --web.enable-lifecycle > /dev/null 2>&1 &
