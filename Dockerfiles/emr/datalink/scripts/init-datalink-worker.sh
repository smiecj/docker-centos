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

pushd {datalink_worker_home}/conf

cp worker_template.properties worker.properties
cp datasource_template.properties datasource.properties

sed -i "s/{MYSQL_HOST}/${MYSQL_HOST}/g" datasource.properties
sed -i "s/{MYSQL_PORT}/${MYSQL_PORT}/g" datasource.properties
sed -i "s/{MYSQL_DB}/${MYSQL_DB}/g" datasource.properties
sed -i "s/{MYSQL_USER}/${MYSQL_USER}/g" datasource.properties
sed -i "s/{MYSQL_PASSWORD}/${MYSQL_PASSWORD}/g" datasource.properties

sed -i "s/{MANAGER_NETTY_ADDRESS}/${MANAGER_NETTY_ADDRESS}/g" worker.properties
sed -i "s/{ZOOKEEPER_ADDRESS}/${ZOOKEEPER_ADDRESS}/g" worker.properties

popd
