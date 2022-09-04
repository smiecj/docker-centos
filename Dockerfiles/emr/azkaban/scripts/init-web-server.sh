#!/bin/bash

web_server_conf_template="azkaban_web_server.properties.template"
web_server_conf="azkaban.properties"

## copy config
cp -f {azkaban_web_server_home}/conf/${web_server_conf_template} {azkaban_web_server_home}/conf/${web_server_conf}

## set config
sed -i "s/jetty.port=.*/jetty.port=${WEB_SERVER_PORT}/g" {azkaban_web_server_home}/conf/${web_server_conf}
sed -i "s/mysql.host=.*/mysql.host=${MYSQL_HOST}/g" {azkaban_web_server_home}/conf/${web_server_conf}
sed -i "s/mysql.port=.*/mysql.port=${MYSQL_PORT}/g" {azkaban_web_server_home}/conf/${web_server_conf}
sed -i "s/mysql.database=.*/mysql.database=${MYSQL_DB}/g" {azkaban_web_server_home}/conf/${web_server_conf}
sed -i "s/mysql.user=.*/mysql.user=${MYSQL_USER}/g" {azkaban_web_server_home}/conf/${web_server_conf}
sed -i "s/mysql.password=.*/mysql.password=${MYSQL_PASSWORD}/g" {azkaban_web_server_home}/conf/${web_server_conf}
