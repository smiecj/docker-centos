#!/bin/bash

# wait mysql start finish
while :
do
    mysql_connect_ret_exec=`mysql -u${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USER} -p${MYSQL_PASSWORD} -e "select version()"`
    mysql_connect_ret=$?
    if [[ 0 == ${mysql_connect_ret} ]]; then
        echo "mysql has start"
        break
    else
        echo "mysql has not start, will wait for it"
        sleep 3
    fi
done

# check azkaban table has created
mysql_check_table_ret=`mysql -u${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USER} -p${MYSQL_PASSWORD} -e "SELECT * FROM ${MYSQL_DB}.executors LIMIT 1"`
check_ret=$?
if [[ 0 == ${check_ret} ]]; then
    echo "azkaban tables has created"
    exit 0
fi

# exec init sql
mysql -u${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DB} < {azkaban_sql_home}/init-azkaban.sql