#!/bin/bash

cp -f {hue_install_path}/desktop/conf/hue.ini_example {hue_install_path}/desktop/conf/hue.ini

sed -i "s/http_port=.*/http_port=${PORT}/g" {hue_install_path}/desktop/conf/hue.ini
### hue connect db
sed -i "s/\[\[database\]\]/\[\[database\]\]\nname=${mysql_db}\nengine=mysql\nhost=${mysql_host}\nport=${mysql_port}\nuser=${mysql_user}\npassword=${mysql_password}\n/g" {hue_install_path}/desktop/conf/hue.ini
### hue interpreter
sed -i "s/\[\[interpreters\]\]/\[\[interpreters\]\]\n\[\[\[mysql\]\]\]\nname = MySQL\ninterface=jdbc\noptions='{\"url\": \"jdbc:mysql:\/\/${mysql_host}:${mysql_port}\/${mysql_db}\", \"driver\": \"{mysql_jdbc_class}\", \"user\": \"${mysql_user}\", \"password\": \"${mysql_password}\"}'\n/g" {hue_install_path}/desktop/conf/hue.ini
