#!/bin/bash

nohup {prometheus_module_home}/prometheus --web.enable-lifecycle --config.file={prometheus_module_home}/prometheus.yml --web.listen-address=:$PROMETHEUS_PORT > {prometheus_log} 2>&1 &
