#!/bin/bash

web_server_conf_template="azkaban_web_server.properties.template"
web_server_conf="azkaban.properties"

user_conf_template="azkaban-users.xml.template"
user_conf="azkaban-users.xml"

## copy config
cp -f {azkaban_web_server_home}/conf/${web_server_conf_template} {azkaban_web_server_home}/conf/${web_server_conf}
cp -f {azkaban_web_server_home}/conf/${user_conf_template} {azkaban_web_server_home}/conf/${user_conf}

## set config
sed -i "s/jetty.port=.*/jetty.port=${WEB_SERVER_PORT}/g" {azkaban_web_server_home}/conf/${web_server_conf}
sed -i "s/mysql.host=.*/mysql.host=${MYSQL_HOST}/g" {azkaban_web_server_home}/conf/${web_server_conf}
sed -i "s/mysql.port=.*/mysql.port=${MYSQL_PORT}/g" {azkaban_web_server_home}/conf/${web_server_conf}
sed -i "s/mysql.database=.*/mysql.database=${MYSQL_DB}/g" {azkaban_web_server_home}/conf/${web_server_conf}
sed -i "s/mysql.user=.*/mysql.user=${MYSQL_USER}/g" {azkaban_web_server_home}/conf/${web_server_conf}
sed -i "s/mysql.password=.*/mysql.password=${MYSQL_PASSWORD}/g" {azkaban_web_server_home}/conf/${web_server_conf}

sed -i "s#{ADMIN_USER}#${ADMIN_USER}#g" {azkaban_web_server_home}/conf/${user_conf}
sed -i "s#{ADMIN_PASSWORD}#${ADMIN_PASSWORD}#g" {azkaban_web_server_home}/conf/${user_conf}
sed -i "s#{USER_NAME}#${USER_NAME}#g" {azkaban_web_server_home}/conf/${user_conf}
sed -i "s#{USER_PASSWORD}#${USER_PASSWORD}#g" {azkaban_web_server_home}/conf/${user_conf}
