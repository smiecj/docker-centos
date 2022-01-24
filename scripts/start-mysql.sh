#!/bin/bash

## 启动 mysql 并初始化 root 密码脚本，暂时不使用

## start mysql
service mysqld restart

## set mysql default password and default account
default_mysql_root_password="root_Test1qaz"
if [[ "$mysql_version" =~ ^8.* ]]; then
    mysql -S /var/lib/mysql/mysql/mysql.sock -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$default_mysql_root_password';"
    service mysqld restart
fi