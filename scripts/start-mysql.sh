#!/bin/bash

## start mysql
service mysqld start

## set mysql default password and default account
default_mysql_root_password = "root_Test1qaz"
if [[ "$mysql_version" =~ ^8.* ]]; then
    mysql -S /var/lib/mysql/mysql/mysql.sock -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$default_mysql_root_password';"
    service mysqld restart
else
fi