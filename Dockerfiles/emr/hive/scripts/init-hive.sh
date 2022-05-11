#!/bin/bash

pushd {hive_module_home}/conf

cp -f hive-site-example.xml hive-site.xml
sed -i "s/\$mysql_host/$mysql_host/g" hive-site.xml
sed -i "s/\$mysql_port/$mysql_port/g" hive-site.xml
sed -i "s/\$mysql_db/$mysql_db/g" hive-site.xml
sed -i "s/\$mysql_user/$mysql_user/g" hive-site.xml
sed -i "s/\$mysql_pwd/$mysql_pwd/g" hive-site.xml

## init db
source /etc/profile
schematool -initSchema -dbType mysql || true

popd