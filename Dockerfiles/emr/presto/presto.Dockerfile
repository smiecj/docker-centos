ARG IMAGE_PRESTO_BASE
FROM ${IMAGE_PRESTO_BASE}

# install presto
ENV PORT=7070
ENV HADOOP_CONF_DIR=/etc/hadoop/conf
ENV DATA_DIR=/opt/data/presto
ENV HIVE_METASTORE_URL=localhost:8093
ENV XMX=4G

ARG maven_repo
ARG module_home
ARG presto_version

# scripts & config
COPY ./etc /tmp/etc
COPY ./scripts/init-presto.sh /tmp
COPY ./scripts/presto-start.sh /usr/local/bin/prestostart
COPY ./scripts/presto-stop.sh /usr/local/bin/prestostop
COPY ./scripts/presto-restart.sh /usr/local/bin/prestorestart

## install
RUN presto_module_home=${module_home}/presto && \
    presto_script_home=${presto_module_home}/scripts && \
    presto_server_folder=presto-server-${presto_version} && \
    presto_server_pkg=${presto_server_folder}.tar.gz && \
    presto_server_pkg_url=${maven_repo}/com/facebook/presto/presto-server/${presto_version}/${presto_server_pkg} && \
    presto_client_jar=presto-cli-${presto_version}-executable.jar && \
    presto_client_jar_url=${maven_repo}/com/facebook/presto/presto-cli/${presto_version}/${presto_client_jar} && \
    mkdir -p ${presto_module_home} && cd ${presto_module_home} && curl -LO ${presto_server_pkg_url} && \
    tar -xzvf ${presto_server_pkg} && rm ${presto_server_pkg} && mv ${presto_server_folder}/* ./ && rm -rf ${presto_server_folder} && \
    curl -LO ${presto_client_jar_url} && mv ${presto_client_jar} ./bin/presto && chmod +x ./bin/presto && \

## copy config
    mkdir -p ${presto_module_home}/etc && mkdir -p ${presto_script_home} && \
    mv /tmp/etc/* ${presto_module_home}/etc/ && rm -r /tmp/etc && \
    mv /tmp/init-presto.sh ${presto_script_home}/ && \

    sed -i "s#{presto_module_home}#${presto_module_home}#g" /usr/local/bin/prestostart && \
    sed -i "s#{presto_module_home}#${presto_module_home}#g" /usr/local/bin/prestostop && \
    sed -i "s#{presto_module_home}#${presto_module_home}#g" ${presto_script_home}/init-presto.sh && \
    chmod +x /usr/local/bin/prestostart && chmod +x /usr/local/bin/prestostop && chmod +x /usr/local/bin/prestorestart && \

## init service
    echo "sh ${presto_script_home}/init-presto.sh && prestostart" >> /init_service