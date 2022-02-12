#!/bin/bash
set -euxo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

## install java, maven
sh ./init-system-java.sh
source /etc/profile

## compile hue source code
hue_code_home=/home/coding/hue
rm -rf $hue_code_home
mkdir -p $hue_code_home
pushd $hue_code_home

curl -LO https://github.com/smiecj/hue/archive/refs/heads/dev_bugfix.zip
unzip dev_bugfix.zip
pushd hue-dev_bugfix

yum -y install cyrus-sasl-devel cyrus-sasl-gssapi cyrus-sasl-plain libffi-devel libxml2 libxml2-devel libxslt libxslt-devel mysql mysql-devel openldap-devel sqlite-devel gmp-devel python2-devel
pushd maven
#curl -LO https://repository.cloudera.com/artifactory/cloudera-repos/com/cloudera/cdh/cdh-root/6.3.3/cdh-root-6.3.3.pom
cp $home_path/components/hue/cdh-root-6.3.3.pom ./
sed -i 's/<version>6.3.3<\/version>/<version>6.3.3<\/version>\n<relativePath>.\/cdh-root-6.3.3.pom<\/relativePath>/g' pom.xml
popd

rm -rf /usr/local/hue
PREFIX=/usr/local make install
popd

popd
rm -rf $hue_code_home

popd

## 后续: 预设置数据库配置