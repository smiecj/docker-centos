#!/bin/bash

source /etc/profile

export AIRFLOW_HOME={airflow_module_home}

nohup airflow celery worker >> {airflow_log_worker} 2>&1 &
