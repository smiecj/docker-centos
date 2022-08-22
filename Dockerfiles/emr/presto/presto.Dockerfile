ARG PRESTO_BASE_IMAGE
FROM ${PRESTO_BASE_IMAGE}

# install presto

ENV PORT=7070
ENV HADOOP_CONF_DIR=/etc/hadoop/conf
ENV DATA_DIR=/home/data/presto
ENV HIVE_METASTORE_URL=localhost:8093

ARG presto_module_home=/home/modules
ARG presto_version=0.273.3
# ARG repo=https://repo1.maven.org/maven2
ARG repo=https://mirrors.huaweicloud.com/repository/maven
ARG presto_server_pkg_url=${repo}/com/facebook/presto/presto-server/${presto_version}/presto-server-${presto_version}.tar.gz
ARG presto_client_jar_url=${repo}/com/facebook/presto/presto-cli/${presto_version}/presto-cli-${presto_version}-executable.jar
ARG presto_server_pkg=presto-server-${presto_version}.tar.gz
ARG presto_client_jar=presto-cli-${presto_version}-executable.jar
ARG presto_server_folder=presto-server-${presto_version}
ARG presto_server_home=${presto_module_home}/${presto_server_folder}
ARG presto_script_home=${presto_server_home}/scripts

## install
RUN mkdir -p ${presto_module_home} && cd ${presto_module_home} && curl -LO ${presto_server_pkg_url} && \
    tar -xzvf ${presto_server_pkg} && rm ${presto_server_pkg} && curl -LO ${presto_client_jar_url} && \
    mv ${presto_client_jar} ${presto_server_folder}/bin/presto && chmod +x ${presto_server_folder}/bin/presto
## copy config
RUN mkdir -p ${presto_server_home}/etc && mkdir -p ${presto_script_home}
COPY ./etc ${presto_server_home}/etc
COPY ./scripts/init-presto.sh ${presto_script_home}/

## start and stop script
COPY ./scripts/presto-start.sh /usr/local/bin/prestostart
COPY ./scripts/presto-stop.sh /usr/local/bin/prestostop
COPY ./scripts/presto-restart.sh /usr/local/bin/prestorestart
RUN sed -i "s#{presto_server_home}#${presto_server_home}#g" /usr/local/bin/prestostart && \
    sed -i "s#{presto_server_home}#${presto_server_home}#g" /usr/local/bin/prestostop && \
    chmod +x /usr/local/bin/prestostart && chmod +x /usr/local/bin/prestostop && chmod +x /usr/local/bin/prestorestart

## init service
RUN echo "sh ${presto_script_home}/init-presto.sh && prestostart" >> /init_service
