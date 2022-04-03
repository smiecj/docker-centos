#!/bin/bash

## 数据库参数
mysql_version=8.0.26
mysql_host=localhost
mysql_port=3306
mysql_db=hive
mysql_user=hive
mysql_pwd=hive

if [ $# -eq 6 ]; then
    mysql_version=$1
    mysql_host=$2
    mysql_port=$3
    mysql_db=$4
    mysql_user=$5
    mysql_pwd=$6
fi

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ./common.sh
. ./env_hdfs.sh
. ./env_hive.sh

## install hdfs
sh ./init-hdfs.sh
source /etc/profile

set -euxo pipefail

## install hive
pushd $hadoop_module_home

rm -f $hive_module_folder

curl -LO $hive_pkg_url
tar -xzvf $hive_pkg

rm -f $hive_pkg

## hive config

pushd $hive_module_folder

pushd conf

### hive-site.xml
cp $home_path/../components/hive/hive-site.xml ./
sed -i "s/\$mysql_host/$mysql_host/g" hive-site.xml
sed -i "s/\$mysql_port/$mysql_port/g" hive-site.xml
sed -i "s/\$mysql_db/$mysql_db/g" hive-site.xml
sed -i "s/\$mysql_user/$mysql_user/g" hive-site.xml
sed -i "s/\$mysql_pwd/$mysql_pwd/g" hive-site.xml

### hive-env
cp hive-env.sh.template hive-env.sh
hdfs_module_home_replace_str=$(echo "$hdfs_module_home" | sed 's/\//\\\//g')
hive_module_home_replace_str=$(echo "$hive_module_home" | sed 's/\//\\\//g')
sed -i "s/# HADOOP_HOME.*/export HADOOP_HOME=$hdfs_module_home_replace_str/g" hive-env.sh
sed -i "s/# HIVE_CONF_DIR.*/export HIVE_CONF_DIR=$hive_module_home_replace_str/g" hive-env.sh

popd

### jdbc jar
pushd lib
curl -LO https://repo1.maven.org/maven2/mysql/mysql-connector-java/$mysql_version/mysql-connector-java-$mysql_version.jar
popd

### set hive conf folder soft link
mkdir -p /etc/hive
ln -s $hive_module_home/conf /etc/hive/conf

### profile: hive bin
echo """
# hive
export HIVE_HOME=$hive_module_home
export PATH=\$PATH:\$HIVE_HOME/bin
""" >> /etc/profile

## init mysql
set +euxo pipefail
source /etc/profile
schematool -initSchema -dbType mysql

## hive scripts
mkdir -p $hive_scripts_home
cp -f $home_path/env_hive.sh $hive_scripts_home
cp -f $home_path/../components/hive/hive-restart.sh $hive_scripts_home
cp -f $home_path/../components/hive/hive-stop.sh $hive_scripts_home
chmod -R 744 $hive_scripts_home

## system
add_systemd_service hive $PATH "" $hive_scripts_home/hive-restart.sh $hive_scripts_home/hive-stop.sh "true"

## log rotate
add_logrorate_task $hive_metastore_log_path metastore
add_logrorate_task $hive_hiveserver2_log_path hvieserver2

popd

popd

popd