ARG IMAGE_JAVA
FROM ${IMAGE_JAVA}

# env
ARG efak_version
ARG github_url

ARG module_home

## env: efak
ENV PORT=8042

## env: mysql
ENV MYSQL_HOST=localhost
ENV MYSQL_PORT=3306
ENV MYSQL_DB=datalink
ENV MYSQL_USER=datalink
ENV MYSQL_PASSWORD=datalink123

## login: admin/123456

## env: zk
ENV ZOOKEEPER_ADDRESS=localhost:2181

# scripts
COPY ./scripts/efak-start.sh /usr/local/bin/efakstart
COPY ./scripts/efak-stop.sh /usr/local/bin/efakstop
COPY ./scripts/efak-restart.sh /usr/local/bin/efakrestart
COPY ./conf/system-config.properties_template /tmp/
COPY ./scripts/init-efak.sh /tmp

# mysql command
RUN yum -y install mysql && \
    kafka_eagle_module_home=${module_home}/efak && \
    kafka_eagle_scripts_home=${kafka_eagle_module_home}/scripts && \
# install
    kafka_eagle_tag=v${efak_version} && \
    kafka_eagle_source_pkg=${kafka_eagle_tag}.tar.gz && \
    kafka_eagle_source_url=${github_url}/smartloli/EFAK/archive/refs/tags/${kafka_eagle_source_pkg} && \
    kafka_eagle_source_folder=EFAK-${efak_version} && \
    kafka_eagle_pkg=efak-web-${efak_version}-bin.tar.gz && \
    kafka_eagle_module_folder=efak-web-${efak_version} && \
    source /etc/profile && mkdir -p ${kafka_eagle_module_home} && \
    cd /tmp && curl -LO ${kafka_eagle_source_url} && tar -xzvf ${kafka_eagle_source_pkg} && \
    rm ${kafka_eagle_source_pkg} && cd ${kafka_eagle_source_folder} && \
    ## fix compile jdk version problem
    ## https://github.com/smartloli/EFAK/pull/337/commits/7869ac6cf5643c00323ffa2f6bae6a779cda1479
    sed -i "s#</properties>#<maven.compiler.source>1.8</maven.compiler.source>\n<maven.compiler.target>1.8</maven.compiler.target>\n</properties>#g" pom.xml && \
    ./build.sh && mv efak-web/target/${kafka_eagle_pkg} ${kafka_eagle_module_home} && \
    cd ${kafka_eagle_module_home} && tar -xzvf ${kafka_eagle_pkg} && mv ${kafka_eagle_module_folder}/* ./ && \
    rm ${kafka_eagle_pkg} && rm -r ${kafka_eagle_module_folder} && rm -r /tmp/${kafka_eagle_source_folder} && rm -rf ${java_repo_home} && \

# KE_HOME
    echo "# kafka eagle" >> /etc/profile && \
    echo "export KE_HOME=${kafka_eagle_module_home}" >> /etc/profile && \

# scripts
    mkdir -p ${kafka_eagle_scripts_home} && \
    mv /tmp/system-config.properties_template ${kafka_eagle_module_home}/conf && \
    mv /tmp/init-efak.sh ${kafka_eagle_scripts_home}/ && \
    sed -i "s#{kafka_eagle_module_home}#${kafka_eagle_module_home}#g" /usr/local/bin/efakstart && \
    sed -i "s#{kafka_eagle_module_home}#${kafka_eagle_module_home}#g" /usr/local/bin/efakstop && \
    chmod +x /usr/local/bin/efakstart && chmod +x /usr/local/bin/efakstop && chmod +x /usr/local/bin/efakrestart && \

# init script
    mkdir -p ${kafka_eagle_scripts_home} && \
    sed -i "s#{kafka_eagle_module_home}#${kafka_eagle_module_home}#g" ${kafka_eagle_scripts_home}/init-efak.sh && \
    echo "sh ${kafka_eagle_scripts_home}/init-efak.sh && efakstart" >> /init_service
