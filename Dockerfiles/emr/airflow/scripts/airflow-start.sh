#!/bin/bash

source /etc/profile

nohup airflow webserver --port $airflow_webserver_port > {airflow_log_webserver} 2>&1 &

nohup airflow scheduler > {airflow_log_scheduler} 2>&1 &
