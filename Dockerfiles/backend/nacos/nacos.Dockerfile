ARG IMAGE_JAVA
FROM ${IMAGE_JAVA} AS java_base

# install nacos
ARG nacos_version

ENV MYSQL_HOST=localhost
ENV MYSQL_PORT=3306
ENV MYSQL_DB=d_nacos
ENV MYSQL_USER=root
ENV MYSQL_PASSWORD=pwd
ENV PORT=8848

## download package
ARG github_url
ARG module_home

COPY scripts/init-nacos.sh /tmp/

RUN nacos_module_home=${module_home}/nacos && \
    nacos_code_pkg=${nacos_version}.tar.gz && \
    nacos_code_folder=nacos-${nacos_version} && \
    nacos_code_download_url=${github_url}/alibaba/nacos/archive/refs/tags/${nacos_code_pkg} && \
    cd /tmp && \
    curl -LO ${nacos_code_download_url} && tar -xzvf ${nacos_code_pkg} && rm -f ${nacos_code_pkg} && \

## compile
    source /etc/profile && cd ${nacos_code_folder} && \
    mvn clean install -Prelease-nacos -U -Dcheckstyle.skip -DskipTests -Dmaven.test.skip=true -Pnet_cn && \

## copy nacos package
    mkdir -p ${nacos_module_home} && \
    cp -r distribution/target/nacos-server-${nacos_version}/nacos/* ${nacos_module_home}/ && \
    rm -r /tmp/${nacos_code_folder} && \

## copy config file for init script
    cd ${nacos_module_home}/conf && cp application.properties application_sample.properties && \

## copy nacos init script

## copy nacos s6 script
### nacos 启动脚本 ./bin/startup.sh 本身就是后台启动方式，所以不适合通过 s6 启动，在容器启动的时候运行即可
# COPY s6/ /etc/
    mv /tmp/init-nacos.sh ${nacos_module_home}/ && \
    echo "sh ${nacos_module_home}/init-nacos.sh && ${nacos_module_home}/bin/startup.sh -m standalone" >> /init_service && \

### nacos restart script
    echo -e """#!/bin/bash\n\
jps -ml | grep 'nacos' | awk '{print \$1}' | xargs --no-run-if-empty kill -9\n\
sleep 3\n\
${nacos_module_home}/bin/startup.sh -m standalone\n\
""" > /usr/local/bin/nacosrestart && chmod +x /usr/local/bin/nacosrestart