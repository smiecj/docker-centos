#!/bin/bash
set -euxo pipefail

#. ./env_mysql.sh

## env init
system_arch=`uname -p`

mysql_version="8.0"
#mysql_version="5.7"
mysql_sub_version="8.0.27-1"
#mysql_sub_version="5.7.36-1"
system_version="el7"
mysql_home=/home/modules/mysql

mysql_server_rpm_name="mysql-server.rpm"
mysql_common_rpm_name="mysql-common.rpm"
mysql_client_rpm_name="mysql-client.rpm"
mysql_client_plugins_rpm_name="mysql-client-plugins.rpm"
mysql_libs_rpm_name="mysql-libs.rpm"

mysql_server_rpm_download_link="https://dev.mysql.com/get/Downloads/MySQL-$mysql_version/mysql-community-server-$mysql_sub_version.$system_version.x86_64.rpm"
mysql_common_rpm_download_link="https://dev.mysql.com/get/Downloads/MySQL-$mysql_version/mysql-community-common-$mysql_sub_version.$system_version.x86_64.rpm"
mysql_client_rpm_download_link="https://dev.mysql.com/get/Downloads/MySQL-$mysql_version/mysql-community-client-$mysql_sub_version.$system_version.x86_64.rpm"
mysql_client_plugins_rpm_download_link="https://dev.mysql.com/get/Downloads/MySQL-$mysql_version/mysql-community-client-plugins-$mysql_sub_version.$system_version.x86_64.rpm"
mysql_libs_rpm_download_link="https://dev.mysql.com/get/Downloads/MySQL-$mysql_version/mysql-community-libs-$mysql_sub_version.$system_version.x86_64.rpm"

if [ "x86_64" == "$system_arch" ]; then
    echo "The system arch is x86_64"
else
    echo "The system arch is $system_arch"
    mysql_server_rpm_download_link="https://dev.mysql.com/get/Downloads/MySQL-$mysql_version/mysql-community-server-$mysql_sub_version.$system_version.aarch64.rpm"
    mysql_common_rpm_download_link="https://dev.mysql.com/get/Downloads/MySQL-$mysql_version/mysql-community-common-$mysql_sub_version.$system_version.aarch64.rpm"
    mysql_client_rpm_download_link="https://dev.mysql.com/get/Downloads/MySQL-$mysql_version/mysql-community-client-$mysql_sub_version.$system_version.aarch64.rpm"
    mysql_client_plugins_rpm_download_link="https://dev.mysql.com/get/Downloads/MySQL-$mysql_version/mysql-community-client-plugins-$mysql_sub_version.$system_version.aarch64.rpm"
    mysql_libs_rpm_download_link="https://dev.mysql.com/get/Downloads/MySQL-$mysql_version/mysql-community-libs-$mysql_sub_version.$system_version.aarch64.rpm"
fi

## install mysql
mkdir -p $mysql_home
rm -rf $mysql_home
cd $mysql_home
wget --no-check-certificate $mysql_server_rpm_download_link -O $mysql_server_rpm_name
wget --no-check-certificate $mysql_common_rpm_download_link -O $mysql_common_rpm_name
wget --no-check-certificate $mysql_client_rpm_download_link -O $mysql_client_rpm_name
wget --no-check-certificate $mysql_client_plugins_rpm_download_link -O $mysql_client_plugins_rpm_name
wget --no-check-certificate $mysql_libs_rpm_download_link -O $mysql_libs_rpm_name

rpm -ivh $mysql_client_plugins_rpm_name
rpm -ivh $mysql_common_rpm_name
rpm -ivh $mysql_libs_rpm_name
rpm -ivh $mysql_client_rpm_name
rpm -ivh $mysql_server_rpm_name

## set mysql config
#### 当前: 在当前仓库提供一个默认的配置
#### 默认配置: mysql_default.cnf
#### 后续需要特别定制化的操作才进行配置替换
'''
cp /etc/my.cnf /etc/my.cnf_bak
cp ../mysql_default.cnf /etc/my.cnf
mkdir -p /home/modules/mysql
mv -f /var/lib/mysql/* /home/modules/mysql
mkdir -p /home/modules/mysql/log
mv /home/modules/mysql/binlog.index /home/modules/mysql/log
chown -R mysql:mysql /home/modules/mysql
'''

## start mysql
service mysqld start

## set mysql default password and default account
default_mysql_root_password = "root_Test1qaz"
if [[ "$mysql_version" =~ ^8.* ]]; then
    mysql -S /var/lib/mysql/mysql/mysql.sock -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$default_mysql_root_password';"
    service mysqld restart
else
fi

## if need: uninstall mysql