#!/bin/bash

source /etc/profile

nohup airflow webserver --port ${AIRFLOW_PORT} > {airflow_log_webserver} 2>&1 &

nohup airflow scheduler > {airflow_log_scheduler} 2>&1 &
