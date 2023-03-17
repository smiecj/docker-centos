#!/bin/bash

source /etc/profile

PREFECT_ORION_API_HOST='0.0.0.0' PREFECT_ORION_API_PORT=${PORT} PREFECT_ORION_UI_API_URL=${API_URL} nohup prefect orion start > {prefect_orion_log} 2>&1 &

# test-queue
nohup prefect agent start -q "test-queue" > {prefect_test_queue_log} 2>&1 &