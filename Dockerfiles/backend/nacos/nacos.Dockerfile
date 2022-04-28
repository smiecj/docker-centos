FROM centos_java AS java_base

# bash
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# install nacos
ARG nacos_version=2.1.0-BETA

ARG MYSQL_HOST=localhost
ARG MYSQL_PORT=3306
ARG MYSQL_DB=d_nacos
ARG MYSQL_USER=root
ARG MYSQL_PASSWORD=pwd

## download package
ARG nacos_code_home=/tmp
ARG nacos_code_download_url=https://github.com/alibaba/nacos/archive/refs/tags/${nacos_version}.tar.gz
ARG nacos_code_pkg=${nacos_version}.tar.gz
ARG nacos_code_folder=nacos-${nacos_version}

RUN mkdir -p ${nacos_code_home} && cd ${nacos_code_home} && \
    curl -LO ${nacos_code_download_url} && tar -xzvf ${nacos_code_pkg} && rm -f ${nacos_code_pkg}

## compile
RUN source ~/.bashrc && cd ${nacos_code_home}/${nacos_code_folder} && \
    mvn clean install -Prelease-nacos -U -DskipTests -Dmaven.test.skip=true

## copy nacos package
ENV nacos_module_home=/home/modules/nacos
RUN mkdir -p ${nacos_module_home}
RUN cd ${nacos_code_home}/${nacos_code_folder} && \
    cp -r distribution/target/nacos-server-${nacos_version}/nacos/* ${nacos_module_home}/ && \
    rm -rf ${nacos_code_home}/${nacos_code_folder}

## config mysql
ARG nacos_config=application.properties
RUN cd ${nacos_module_home}/conf && sed -i "s/# db.num.*/db.num=1/g" $nacos_config && \
    sed -i "s/# db.url.0.*/db.url.0=jdbc:mysql:\/\/$MYSQL_HOST:$MYSQL_PORT\/$MYSQL_DB?characterEncoding=utf8\&connectTimeout=1000\&socketTimeout=3000\&autoReconnect=true\&useUnicode=true\&useSSL=false\&serverTimezone=UTC/g" $nacos_config && \
    sed -i "s/# db.user.0.*/db.user.0=$MYSQL_USER/g" $nacos_config && \
    sed -i "s/# db.password.0.*/db.password.0=$MYSQL_PASSWORD/g" $nacos_config

## copy nacos s6 script
### nacos 启动脚本 ./bin/startup.sh 本身就是后台启动方式，所以不适合通过 s6 启动，在容器启动的时候运行即可
# COPY s6/ /etc/

RUN echo "${nacos_module_home}/bin/startup.sh -m standalone" >> /init_service

### nacos restart script
RUN echo -e """#!/bin/bash\n\
jps -ml | grep 'nacos' | awk '{print \$1}' | xargs --no-run-if-empty kill -9\n\
sleep 3\n\
${nacos_module_home}/bin/startup.sh -m standalone\n\
""" > /usr/local/bin/nacosrestart && chmod +x /usr/local/bin/nacosrestart