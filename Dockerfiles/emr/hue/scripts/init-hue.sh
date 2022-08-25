#!/bin/bash

cp -f {hue_install_path}/desktop/conf/hue.ini_example {hue_install_path}/desktop/conf/hue.ini

sed -i "s/http_port=.*/http_port=${PORT}/g" {hue_install_path}/desktop/conf/hue.ini
### hue connect db
sed -i "s/\[\[database\]\]/\[\[database\]\]\nname=${MYSQL_DB}\nengine=mysql\nhost=${MYSQL_HOST}\nport=${MYSQL_PORT}\nuser=${MYSQL_USER}\npassword=${MYSQL_PASSWORD}\n/g" {hue_install_path}/desktop/conf/hue.ini
### hue interpreter
sed -i "s/\[\[interpreters\]\]/\[\[interpreters\]\]\n\[\[\[mysql\]\]\]\nname = MySQL\ninterface=jdbc\noptions='{\"url\": \"jdbc:mysql:\/\/${MYSQL_HOST}:${MYSQL_PORT}\/${MYSQL_DB}\", \"driver\": \"{mysql_jdbc_class}\", \"user\": \"${MYSQL_USER}\", \"password\": \"${MYSQL_PASSWORD}\"}'\n/g" {hue_install_path}/desktop/conf/hue.ini
