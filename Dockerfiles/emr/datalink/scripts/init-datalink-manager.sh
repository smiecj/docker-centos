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

pushd {datalink_manager_home}/conf

cp manager_template.properties manager.properties
cp datasource_template.properties datasource.properties

sed -i "s/{MYSQL_HOST}/${MYSQL_HOST}/g" datasource.properties
sed -i "s/{MYSQL_PORT}/${MYSQL_PORT}/g" datasource.properties
sed -i "s/{MYSQL_DB}/${MYSQL_DB}/g" datasource.properties
sed -i "s/{MYSQL_USER}/${MYSQL_USER}/g" datasource.properties
sed -i "s/{MYSQL_PASSWORD}/${MYSQL_PASSWORD}/g" datasource.properties

sed -i "s/{MANAGER_NETTY_PORT}/${MANAGER_NETTY_PORT}/g" manager.properties
sed -i "s/{MANAGER_HTTP_PORT}/${MANAGER_HTTP_PORT}/g" manager.properties
sed -i "s/{ZOOKEEPER_ADDRESS}/${ZOOKEEPER_ADDRESS}/g" manager.properties

popd
