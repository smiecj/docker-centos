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

sed -i "s#azkaban.native.lib=.*#azkaban.native.lib={azkaban_exec_server_home}/lib/native#g" {azkaban_exec_server_home}/plugins/jobtypes/commonprivate.properties
sed -i "s#azkaban.group.name=.*#azkaban.group.name=${GROUP_NAME}#g" {azkaban_exec_server_home}/plugins/jobtypes/commonprivate.properties

## add user and group
check_group_output=`getent group ${GROUP_NAME}`
check_group_ret=$?
if [ 0 != ${check_group_ret} ]; then
    groupadd ${GROUP_NAME}
fi

to_add_user=("${USER_NAME}")
for current_user in ${to_add_user[@]}
do
    check_user_output=`id ${current_user}`
    check_user_ret=$?
    if [ 0 != ${check_user_ret} ]; then
        useradd ${current_user} -g ${GROUP_NAME}
    fi
done