#!/bin/bash

source /etc/profile

nohup airflow celery worker >> {airflow_log_worker} 2>&1 &
