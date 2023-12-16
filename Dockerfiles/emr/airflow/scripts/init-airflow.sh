#!/bin/bash

## create admin user
export AIRFLOW_HOME={airflow_module_home}

source /etc/profile

## wait mysql start when mysql configured
if [ -n "${MYSQL_HOST}" ]; then
    while :
    do
        
        ## if this pod db not init, need check table exists or not
        if [ "true" != "${AIRFLOW_DB_INIT}" ]; then
            mysql_connect_ret_exec=`mysql -u${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USER} -p${MYSQL_PASSWORD} -D${MYSQL_DB} -e "select count(1) from dag"`
        else
            mysql_connect_ret_exec=`mysql -u${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USER} -p${MYSQL_PASSWORD} -e "select version()"`
        fi
        
        mysql_connect_ret=$?
        if [[ 0 == ${mysql_connect_ret} ]]; then
            echo "mysql has start"
            break
        else
            echo "mysql has not start, will wait for it"
            sleep 3
        fi
    done
fi

pushd ${AIRFLOW_HOME}

if [ ! -f airflow.cfg ]; then
    # default config
    airflow config list --defaults > airflow.cfg
fi

# mysql config
if [ -n "${MYSQL_HOST}" ]; then
    sed -i "s#.*sql_alchemy_conn = .*#sql_alchemy_conn = mysql+pymysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DB}#g" airflow.cfg
fi

# only webserver need init db
if [ "true" == "${AIRFLOW_DB_INIT}" ]; then
    airflow db init
    airflow users create \
        --username ${ADMIN_USER_NAME} \
        --password ${ADMIN_USER_PASSWORD} \
        --firstname ${ADMIN_USER_FIRSTNAME} \
        --lastname ${ADMIN_USER_LASTNAME} \
        --role Admin \
        --email ${ADMIN_USER_MAIL}
fi

sed -i "s#.*web_server_port = .*#web_server_port = ${AIRFLOW_PORT}#g" airflow.cfg
sed -i "s#.*secret_key = .*#secret_key = ${FLASK_SECRET_KEY}#g" airflow.cfg

# celery and executor

sed -i "s#.*executor = .*#executor = ${EXECUTOR}#g" airflow.cfg
if [ "${EXECUTOR}" == "CeleryExecutor" ]; then
    if [ "${CELERY_BROKER_TYPE}" == "mysql" ]; then
        sed -i "s#.*broker_url = .*#broker_url = sqla+mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DB}#g" airflow.cfg
    fi
fi

popd