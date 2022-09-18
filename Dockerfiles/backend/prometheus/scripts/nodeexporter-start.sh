#!/bin/bash

nohup {node_exporter_home}/node_exporter --web.listen-address=":${NODE_EXPORTER_PORT}"  > /dev/null 2>&1 &
