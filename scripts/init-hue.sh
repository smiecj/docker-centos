#!/bin/bash

## 数据库参数
mysql_host=localhost
mysql_port=3306
mysql_user=hue
mysql_password=hue123
mysql_db=hue

if [ $# -eq 5 ]; then
    mysql_host=$1
    mysql_port=$2
    mysql_user=$3
    mysql_password=$4
    mysql_db=$5
fi

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ./env_hue.sh

## install java, maven, node
sh ./init-system-java.sh
sh ./init-system-node.sh
source /etc/profile

## compile hue source code
hue_code_home=/home/coding/hue
rm -rf $hue_code_home
mkdir -p $hue_code_home
pushd $hue_code_home

#curl -LO https://github.com/smiecj/hue/archive/refs/heads/dev_bugfix.zip
curl -LO https://gitee.com/atamagaii/hue/repository/archive/dev_bugfix.zip
unzip dev_bugfix.zip
pushd hue-dev_bugfix

yum -y install cyrus-sasl-devel cyrus-sasl-gssapi cyrus-sasl-plain libffi-devel libxml2 libxml2-devel libxslt libxslt-devel mysql mysql-devel openldap-devel sqlite-devel gmp-devel python2-devel
pushd maven
#curl -LO https://repository.cloudera.com/artifactory/cloudera-repos/com/cloudera/cdh/cdh-root/6.3.3/cdh-root-6.3.3.pom
cp -f $home_path/../components/hue/cdh-root-6.3.3.pom ./
sed -i 's/<version>6.3.3<\/version>/<version>6.3.3<\/version>\n<relativePath>.\/cdh-root-6.3.3.pom<\/relativePath>/g' pom.xml
popd

rm -rf $hue_install_path
PREFIX=$hue_install_prefix make install
popd

popd
rm -rf $hue_code_home

## hue config
mkdir -p $hue_install_path/build/static/desktop
yes | cp -r $hue_install_path/desktop/core/src/desktop/static/desktop/js $hue_install_path/build/static/desktop

pushd $hue_install_path/desktop/conf
mv pseudo-distributed.ini.tmpl hue.ini
sed -i "s/\[\[database\]\]/\[\[database\]\]\nname=$mysql_db\nengine=mysql\nhost=$mysql_host\nport=$mysql_port\nuser=$mysql_user\npassword=$mysql_password\n/g" hue.ini
sed -i 's/http_port=.*/http_port=8281/g' hue.ini
popd

### cp hue sync db and restart script, need user execute manaully
cp -f ./env_hue.sh /usr/local/bin
cp -f $home_path/../components/hue/hue-restart.sh /usr/local/bin/huerestart
chmod +x /usr/local/bin/huerestart
cp -f $home_path/../components/hue/hue-stop.sh /usr/local/bin/huestop
chmod +x /usr/local/bin/huestop

cp -f $home_path/../components/hue/hue-syncdb.sh /usr/local/bin/huesyncdb
chmod +x /usr/local/bin/huesyncdb

popd

## 登录后，需要手动启动hue
### huesyncdb
### huerestart
