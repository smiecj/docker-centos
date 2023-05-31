#!/bin/bash

# portal

pushd {apollo_portal_home}

sed -i "s#spring\.datasource\.url.*#spring.datasource.url=jdbc:mysql://${MYSQL_HOST}:${MYSQL_PORT}/ApolloPortalDB?characterEncoding=utf8\&serverTimezone=Asia/Shanghai#g" config/application-github.properties
sed -i "s#spring.datasource.username.*#spring.datasource.username=${MYSQL_USER}#g" config/application-github.properties
sed -i "s#spring.datasource.password.*#spring.datasource.password=${MYSQL_PASSWORD}#g" config/application-github.properties

sed -i "s#dev.meta=.*#dev.meta=http://localhost:${configservice_port}#g" config/apollo-env.properties

popd

# configservice

pushd {apollo_configservice_home}

sed -i "s#spring\.datasource\.url.*#spring.datasource.url=jdbc:mysql://${MYSQL_HOST}:${MYSQL_PORT}/ApolloConfigDB?characterEncoding=utf8\&serverTimezone=Asia/Shanghai#g" config/application-github.properties
sed -i "s#spring.datasource.username.*#spring.datasource.username=${MYSQL_USER}#g" config/application-github.properties
sed -i "s#spring.datasource.password.*#spring.datasource.password=${MYSQL_PASSWORD}#g" config/application-github.properties

popd

# adminservice

pushd {apollo_adminservice_home}

sed -i "s#spring\.datasource\.url.*#spring.datasource.url=jdbc:mysql://${MYSQL_HOST}:${MYSQL_PORT}/ApolloConfigDB?characterEncoding=utf8\&serverTimezone=Asia/Shanghai#g" config/application-github.properties
sed -i "s#spring.datasource.username.*#spring.datasource.username=${MYSQL_USER}#g" config/application-github.properties
sed -i "s#spring.datasource.password.*#spring.datasource.password=${MYSQL_PASSWORD}#g" config/application-github.properties

popd