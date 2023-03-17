#!/bin/bash

source /etc/profile

export AIRFLOW_HOME={airflow_module_home}

nohup airflow webserver > {airflow_log_webserver} 2>&1 &

nohup airflow scheduler > {airflow_log_scheduler} 2>&1 &
