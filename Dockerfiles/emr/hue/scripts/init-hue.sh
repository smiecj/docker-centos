#!/bin/bash

hue_conf={hue_install_path}/desktop/conf/hue.ini

cp -f {hue_install_path}/desktop/conf/hue.ini_example ${hue_conf}

## basic
### send debug msg
sed -i "s/send_dbug_messages.*/send_dbug_messages=false/g" ${hue_conf}

### disable collect usage
sed -i "s/## collect_usage.*/collect_usage=false/g" ${hue_conf}

### timezone
sed -i "s#time_zone=.*#time_zone=${TIME_ZONE}#g" ${hue_conf}

## mysql
sed -i "s/http_port=.*/http_port=${PORT}/g" ${hue_conf}
### hue connect db
sed -i "s/\[\[database\]\]/\[\[database\]\]\nname=${MYSQL_DB}\nengine=mysql\nhost=${MYSQL_HOST}\nport=${MYSQL_PORT}\nuser=${MYSQL_USER}\npassword=${MYSQL_PASSWORD}\n/g" ${hue_conf}
### hue interpreter (mysql, impala...)
#### mysql
password=$(echo ${MYSQL_PASSWORD} | jq -Rr '@uri')
sed -i "s/\[\[interpreters\]\]/\[\[interpreters\]\]\n\[\[\[hue_mysql\]\]\]\nname = ${HUE_MYSQL_QUERIER_NAME}\ninterface=sqlalchemy\noptions='{\"url\": \"mysql+mysqldb:\/\/${MYSQL_USER}:${password}@${MYSQL_HOST}:${MYSQL_PORT}\/mysql?charset=utf8mb4\"}'\n/g" ${hue_conf}

## hive
if [[ -n "${HIVE_SERVER_HOST}" ]]; then
    sed -i "s/.*hive_server_host=.*/  hive_server_host=${HIVE_SERVER_HOST}/g" ${hue_conf}
    sed -i "s/.*hive_server_port=.*/  hive_server_port=${HIVE_SERVER_PORT}/g" ${hue_conf}
    sed -i "s/\[\[interpreters\]\]/\[\[interpreters\]\]\n\[\[\[hive\]\]\]\nname = Hive\ninterface=hiveserver2\n/g" ${hue_conf}
fi

## hdfs
if [[ -n "${DEFAULTFS}" ]]; then
    sed -i "s#.*fs_defaultfs=.*#      fs_defaultfs=${DEFAULTFS}#g" ${hue_conf}
    sed -i "s#.*webhdfs_url=.*#      webhdfs_url=http://${WEBHDFS_ADDRESS}/webhdfs/v1#g" ${hue_conf}
fi

## presto
if [[ -n "${PRESTO_SERVER}" ]]; then
    sed -i "s#\[\[interpreters\]\]#[[interpreters]]\n[[[presto]]]\nname=presto\ninterface=sqlalchemy\noptions='{\"url\": \"presto://hive@${PRESTO_SERVER}/${PRESTO_HIVE_CATALOG}/default\"}'\n#g" ${hue_conf}
fi