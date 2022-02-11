#!/bin/bash
set -euxo pipefail

#. ./env_mysql.sh

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

## env init
system_arch=`uname -p`

mysql_version="8.0"
#mysql_version="5.7"
mysql_sub_version="8.0.27-1"
#mysql_sub_version="5.7.36-1"
system_version="el7"
mysql_home=/home/modules/mysql
mysql_repo_home=/home/modules/mysql/repo

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
rm -rf $mysql_repo_home
mkdir -p $mysql_repo_home
pushd $mysql_repo_home
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

## enable mysql auto start
systemctl enable mysqld.service

## if need: uninstall mysql

popd
rm -rf $mysql_repo_home

## copy mysql password reset script
mysql_reset_password_bin=/usr/local/bin/mysqlresetpassword
cp ./mysql-reset-password.sh $mysql_reset_password_bin
chmod +x $mysql_reset_password_bin

popd