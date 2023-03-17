#!/bin/bash

## create admin user
export AIRFLOW_HOME={airflow_module_home}

if [ ! -f ${AIRFLOW_HOME}/airflow.cfg ]; then
    airflow db init
    airflow users create \
        --username ${ADMIN_USER_NAME} \
        --password ${ADMIN_USER_PASSWORD} \
        --firstname ${ADMIN_USER_FIRSTNAME} \
        --lastname ${ADMIN_USER_LASTNAME} \
        --role Admin \
        --email ${ADMIN_USER_MAIL}
fi

sed -i "s#web_server_port = .*#web_server_port = ${AIRFLOW_PORT}#g" ${AIRFLOW_HOME}/airflow.cfg