#!/bin/bash

cp -f {hue_install_path}/desktop/conf/hue.ini_example {hue_install_path}/desktop/conf/hue.ini

## basic
### send debug msg
sed -i "s/send_dbug_messages.*/send_dbug_messages=false/g" {hue_install_path}/desktop/conf/hue.ini

### disable collect usage
sed -i "s/## collect_usage.*/collect_usage=false/g" {hue_install_path}/desktop/conf/hue.ini

### timezone
sed -i "s#time_zone=.*#time_zone=${TIME_ZONE}#g" {hue_install_path}/desktop/conf/hue.ini

## mysql
sed -i "s/http_port=.*/http_port=${PORT}/g" {hue_install_path}/desktop/conf/hue.ini
### hue connect db
sed -i "s/\[\[database\]\]/\[\[database\]\]\nname=${MYSQL_DB}\nengine=mysql\nhost=${MYSQL_HOST}\nport=${MYSQL_PORT}\nuser=${MYSQL_USER}\npassword=${MYSQL_PASSWORD}\n/g" {hue_install_path}/desktop/conf/hue.ini
### hue interpreter (mysql, impala...)
#### mysql
sed -i "s/\[\[interpreters\]\]/\[\[interpreters\]\]\n\[\[\[hue_mysql\]\]\]\nname = ${HUE_MYSQL_QUERIER_NAME}\ninterface=rdbms\n/g" {hue_install_path}/desktop/conf/hue.ini
sed -i "s/\[\[databases\]\]/\[\[databases\]\]\n\[\[\[hue_mysql\]\]\]\nnice_name = hue_mysql\nengine=mysql\nhost=${MYSQL_HOST}\nport=${MYSQL_PORT}\nuser=${MYSQL_USER}\npassword=${MYSQL_PASSWORD}\noptions='{\"charset\": \"utf8\"}'\n/g" {hue_install_path}/desktop/conf/hue.ini

## hive
if [[ -n "${HIVE_SERVER_HOST}" ]]; then
    sed -i "s/.*hive_server_host=.*/  hive_server_host=${HIVE_SERVER_HOST}/g" {hue_install_path}/desktop/conf/hue.ini
    sed -i "s/.*hive_server_port=.*/  hive_server_port=${HIVE_SERVER_PORT}/g" {hue_install_path}/desktop/conf/hue.ini
    sed -i "s/\[\[interpreters\]\]/\[\[interpreters\]\]\n\[\[\[hive\]\]\]\nname = Hive\ninterface=hiveserver2\n/g" {hue_install_path}/desktop/conf/hue.ini
fi

## hdfs
if [[ -n "${DEFAULTFS}" ]]; then
    sed -i "s#.*fs_defaultfs=.*#      fs_defaultfs=${DEFAULTFS}#g" {hue_install_path}/desktop/conf/hue.ini
    sed -i "s#.*webhdfs_url=.*#      webhdfs_url=http://${WEBHDFS_ADDRESS}/webhdfs/v1#g" {hue_install_path}/desktop/conf/hue.ini
fi