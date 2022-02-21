#!/bin/bash
#set -euxo pipefail

## 数据库参数
mysql_addr=localhost:3306
mysql_user=root
mysql_password=root123
mysql_db=wordpress

if [ $# -eq 4 ]; then
    mysql_addr=$1
    mysql_user=$2
    mysql_password=$3
    mysql_db=$4
fi

## 版本号
### 所有版本: https://cn.wordpress.org/download/releases/
wordpress_version=5.0.4

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

## httpd
yum -y install httpd
systemctl enable httpd

## php
yum -y install epel-release
yum -y install php php-fpm php-mysqlnd

### fpm config
sed -i 's/listen.acl_users/;listen.acl_users/g' /etc/php-fpm.d/www.conf
sed -i 's/;listen.mode/listen.mode/g' /etc/php-fpm.d/www.conf
sed -i 's/listen.mode.*/listen.mode = 0777/g' /etc/php-fpm.d/www.conf

## wordpress
pushd /tmp
wordpress_pkg=wordpress-$wordpress_version-zh_CN.tar.gz
curl -LO https://cn.wordpress.org/$wordpress_pkg
tar -xzvf $wordpress_pkg
rsync -avP ./wordpress/ /var/www/html/
mkdir -p /var/www/html/wp-content/uploads
chown -R apache:apache /var/www/html/*
popd

### wordpress config
pushd /var/www/html/
cp wp-config-sample.php wp-config.php
sed -i "s/'localhost'/'$mysql_addr'/g" wp-config.php
sed -i "s/username_here/$mysql_user/g" wp-config.php
sed -i "s/password_here/$mysql_password/g" wp-config.php
sed -i "s/database_name_here/$mysql_db/g" wp-config.php
popd

popd