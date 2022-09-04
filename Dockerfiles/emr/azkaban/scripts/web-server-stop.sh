#!/bin/bash

azkaban_web_server_pid=`jps -ml | grep azkaban.webapp.AzkabanWebServer | sed 's/ .*//g'`
if [ "" != "${azkaban_web_server_pid}" ]; then
    {azkaban_web_server_home}/bin/shutdown-web.sh
fi
