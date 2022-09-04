#!/bin/bash

exec_server_conf_template="azkaban_exec_server.properties.template"
exec_server_conf="azkaban.properties"

## copy config
cp -f {azkaban_exec_server_home}/conf/${exec_server_conf_template} {azkaban_exec_server_home}/conf/${exec_server_conf}

## set config
sed -i "s/executor.port=.*/executor.port=${EXEC_SERVER_PORT}/g" {azkaban_exec_server_home}/conf/${exec_server_conf}
sed -i "s/mysql.host=.*/mysql.host=${MYSQL_HOST}/g" {azkaban_exec_server_home}/conf/${exec_server_conf}
sed -i "s/mysql.port=.*/mysql.port=${MYSQL_PORT}/g" {azkaban_exec_server_home}/conf/${exec_server_conf}
sed -i "s/mysql.database=.*/mysql.database=${MYSQL_DB}/g" {azkaban_exec_server_home}/conf/${exec_server_conf}
sed -i "s/mysql.user=.*/mysql.user=${MYSQL_USER}/g" {azkaban_exec_server_home}/conf/${exec_server_conf}
sed -i "s/mysql.password=.*/mysql.password=${MYSQL_PASSWORD}/g" {azkaban_exec_server_home}/conf/${exec_server_conf}

sed -i "s#azkaban.webserver.url=.*#azkaban.webserver.url=http://${WEB_SERVER_HOST}:${WEB_SERVER_PORT}#g" {azkaban_exec_server_home}/conf/${exec_server_conf}