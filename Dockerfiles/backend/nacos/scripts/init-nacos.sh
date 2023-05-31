#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path/conf

# init nacos config
cp -f application_sample.properties application.properties
sed -i "s/# db.num.*/db.num=1/g" application.properties
sed -i "s/# db.url.0.*/db.url.0=jdbc:mysql:\/\/$MYSQL_HOST:$MYSQL_PORT\/$MYSQL_DB?characterEncoding=utf8\&connectTimeout=1000\&socketTimeout=3000\&autoReconnect=true\&useUnicode=true\&useSSL=false\&serverTimezone=UTC/g" application.properties
sed -i "s/# db.user.0.*/db.user.0=$MYSQL_USER/g" application.properties
sed -i "s/# db.password.0.*/db.password.0=$MYSQL_PASSWORD/g" application.properties
sed -i "s/^server.port=.*/server.port=$PORT/g" application.properties
sed -i "s/^server.port=.*/server.port=$PORT/g" application.properties

popd