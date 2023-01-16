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

pushd {kafka_eagle_module_home}/conf

cp system-config.properties_template system-config.properties

sed -i "s/{MYSQL_HOST}/${MYSQL_HOST}/g" system-config.properties
sed -i "s/{MYSQL_PORT}/${MYSQL_PORT}/g" system-config.properties
sed -i "s/{MYSQL_DB}/${MYSQL_DB}/g" system-config.properties
sed -i "s/{MYSQL_USER}/${MYSQL_USER}/g" system-config.properties
sed -i "s/{MYSQL_PASSWORD}/${MYSQL_PASSWORD}/g" system-config.properties

sed -i "s/{ZOOKEEPER_ADDRESS}/${ZOOKEEPER_ADDRESS}/g" system-config.properties

sed -i "s/{PORT}/${PORT}/g" system-config.properties

popd