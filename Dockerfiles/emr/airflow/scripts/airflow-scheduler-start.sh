#!/bin/bash

source /etc/profile

export AIRFLOW_HOME={airflow_module_home}

nohup airflow scheduler >> {airflow_log_scheduler} 2>&1 &
