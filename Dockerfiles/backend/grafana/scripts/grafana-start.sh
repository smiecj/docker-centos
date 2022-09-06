#!/bin/bash

nohup {grafana_module_home}/bin/grafana-server --homepath "{grafana_module_home}" --config "{grafana_module_home}/conf/custom.ini" > {grafana_log} 2>&1 &