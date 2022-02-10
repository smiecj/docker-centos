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

#mysql_repo_url="https://cdn.mysql.com/Downloads"
mysql_repo_url="https://mirrors.tuna.tsinghua.edu.cn/mysql/downloads"

mysql_server_rpm_name="mysql-server.rpm"
mysql_common_rpm_name="mysql-common.rpm"
mysql_client_rpm_name="mysql-client.rpm"
mysql_client_plugins_rpm_name="mysql-client-plugins.rpm"
mysql_libs_rpm_name="mysql-libs.rpm"

mysql_server_rpm_download_link="$mysql_repo_url/MySQL-$mysql_version/mysql-community-server-$mysql_sub_version.$system_version.x86_64.rpm"
mysql_common_rpm_download_link="$mysql_repo_url/MySQL-$mysql_version/mysql-community-common-$mysql_sub_version.$system_version.x86_64.rpm"
mysql_client_rpm_download_link="$mysql_repo_url/MySQL-$mysql_version/mysql-community-client-$mysql_sub_version.$system_version.x86_64.rpm"
mysql_client_plugins_rpm_download_link="$mysql_repo_url/MySQL-$mysql_version/mysql-community-client-plugins-$mysql_sub_version.$system_version.x86_64.rpm"
mysql_libs_rpm_download_link="$mysql_repo_url/MySQL-$mysql_version/mysql-community-libs-$mysql_sub_version.$system_version.x86_64.rpm"

if [ "x86_64" == "$system_arch" ]; then
    echo "The system arch is x86_64"
else
    echo "The system arch is $system_arch"
    mysql_server_rpm_download_link="$mysql_repo_url/MySQL-$mysql_version/mysql-community-server-$mysql_sub_version.$system_version.aarch64.rpm"
    mysql_common_rpm_download_link="$mysql_repo_url/MySQL-$mysql_version/mysql-community-common-$mysql_sub_version.$system_version.aarch64.rpm"
    mysql_client_rpm_download_link="$mysql_repo_url/MySQL-$mysql_version/mysql-community-client-$mysql_sub_version.$system_version.aarch64.rpm"
    mysql_client_plugins_rpm_download_link="$mysql_repo_url/MySQL-$mysql_version/mysql-community-client-plugins-$mysql_sub_version.$system_version.aarch64.rpm"
    mysql_libs_rpm_download_link="$mysql_repo_url/MySQL-$mysql_version/mysql-community-libs-$mysql_sub_version.$system_version.aarch64.rpm"
fi

## install mysql
rm -rf $mysql_home
mkdir -p $mysql_home
cd $mysql_home
curl -Lo $mysql_server_rpm_name $mysql_server_rpm_download_link
curl -Lo $mysql_common_rpm_name $mysql_common_rpm_download_link
curl -Lo $mysql_client_rpm_name $mysql_client_rpm_download_link
curl -Lo $mysql_client_plugins_rpm_name $mysql_client_plugins_rpm_download_link
curl -Lo $mysql_libs_rpm_name $mysql_libs_rpm_download_link

rpm -ivh $mysql_client_plugins_rpm_name
rpm -ivh $mysql_common_rpm_name
rpm -ivh $mysql_libs_rpm_name
rpm -ivh $mysql_client_rpm_name
rpm -ivh $mysql_server_rpm_name

## set mysql config
#### 当前: 在当前仓库提供一个默认的配置
#### 默认配置: mysql_default.cnf
#### 后续需要特别定制化的操作才进行配置替换
#cp /etc/my.cnf /etc/my.cnf_bak
#cp ../mysql_default.cnf /etc/my.cnf
#mkdir -p $mysql_home
#mv -f /var/lib/mysql/* $mysql_home
#mkdir -p $mysql_home/log
#mv /var/lib/mysql/binlog.index $mysql_home/log
#chown -R mysql:mysql $mysql_home

## if need: uninstall mysql