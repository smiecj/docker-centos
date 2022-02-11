#!/bin/bash
set -euxo pipefail

## 重置 mysql 密码，仅适用于第一次启动后调用，需要用户在启动容器后自行执行 mysqlresetpassword 来调用

## set mysql root user default password
default_mysql_root_password="root_Test1qaz"
origin_mysql_password=`cat /var/log/mysqld.log | grep 'temporary password' | sed 's/.*temporary password.* //g'`
mysql_version=`mysql -V`
if [[ "$mysql_version" =~ .*8.[0-9]+.[0-9]+ ]]; then
    mysql -uroot -p"$origin_mysql_password" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$default_mysql_root_password';" --connect-expired-password
    systemctl restart mysqld.service
    mysql -uroot -p"$default_mysql_root_password" -e "UPDATE mysql.user SET host = '%' WHERE user = 'root'";
    systemctl restart mysqld.service
fi