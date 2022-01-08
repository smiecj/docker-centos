#!/bin/bash
#set -euxo pipefail

. ./common.sh

## env init
system_arch=`uname -p`

mysql_version="8.0"
#mysql_version="5.7.36"
mysql_sub_version="8.0.27-1"
system_version="el7"
mysql_home=/home/modules/mysql

mysql_server_rpm_name="mysql-server.rpm"
mysql_common_rpm_name="mysql-common.rpm"
mysql_client_rpm_name="mysql-client.rpm"
mysql_libs_rpm_name="mysql-libs.rpm"

mysql_server_rpm_download_link="https://dev.mysql.com/get/Downloads/MySQL-$mysql_version/mysql-community-server-$mysql_sub_version.$system_version.x86_64.rpm"
mysql_common_rpm_download_link="https://dev.mysql.com/get/Downloads/MySQL-$mysql_version/mysql-community-common-$mysql_sub_version.$system_version.x86_64.rpm"
mysql_client_rpm_download_link="https://dev.mysql.com/get/Downloads/MySQL-$mysql_version/mysql-community-client-$mysql_sub_version.$system_version.x86_64.rpm"
mysql_libs_rpm_download_link="https://dev.mysql.com/get/Downloads/MySQL-$mysql_version/mysql-community-libs-$mysql_sub_version.$system_version.x86_64.rpm"

if [ "x86_64" == "$system_arch" ]; then
    echo "The system arch is x86_64"
else
    echo "The system arch is $system_arch"
    mysql_server_rpm_download_link="https://dev.mysql.com/get/Downloads/MySQL-$mysql_version/mysql-community-server-$mysql_sub_version.$system_version.aarch64.rpm"
    mysql_common_rpm_download_link="https://dev.mysql.com/get/Downloads/MySQL-$mysql_version/mysql-community-common-$mysql_sub_version.$system_version.aarch64.rpm"
    mysql_client_rpm_download_link="https://dev.mysql.com/get/Downloads/MySQL-$mysql_version/mysql-community-client-$mysql_sub_version.$system_version.aarch64.rpm"
    mysql_libs_rpm_download_link="https://dev.mysql.com/get/Downloads/MySQL-$mysql_version/mysql-community-libs-$mysql_sub_version.$system_version.aarch64.rpm"
fi

## install some basic package, eg: yum install gcc
install_basic_tools

## install mysql
mkdir -p $mysql_home
cd $mysql_home
wget $mysql_server_rpm -O $mysql_server_rpm_name
wget $mysql_common_rpm -O $mysql_common_rpm_name
wget $mysql_client_rpm -O $mysql_client_rpm_name
wget $mysql_libs_rpm -O $mysql_libs_rpm_name

rpm -ivh $mysql_server_rpm_name
rpm -ivh $mysql_common_rpm_name
rpm -ivh $mysql_client_rpm_name
rpm -ivh $mysql_libs_rpm_name

## set mysql config
### todo
#### sed /etc/my.ini ...

## start mysql
service mysqld start

## set mysql default password and default account
#### todo: mysql -uroot ... -e "ALTER ..."


## if need: uninstall mysql