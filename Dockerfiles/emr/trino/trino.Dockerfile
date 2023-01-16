ARG IMAGE_TRINO_BASE
FROM ${IMAGE_TRINO_BASE}

# install trino
ENV PORT=7070
ENV HADOOP_CONF_DIR=/etc/hadoop/conf
ENV DATA_DIR=/opt/data/trino
ENV HIVE_METASTORE_URL=localhost:8093
ENV XMX=4G

ARG maven_repo
ARG module_home
ARG trino_version

# scripts & config
COPY ./etc /tmp/etc
COPY ./scripts/init-trino.sh /tmp
COPY ./scripts/trino-start.sh /usr/local/bin/trinostart
COPY ./scripts/trino-stop.sh /usr/local/bin/trinostop
COPY ./scripts/trino-restart.sh /usr/local/bin/trinorestart

## install
RUN trino_module_home=${module_home}/trino && \
    trino_script_home=${trino_module_home}/scripts && \
    trino_server_folder=trino-server-${trino_version} && \
    trino_server_pkg=${trino_server_folder}.tar.gz && \
    trino_server_pkg_url=${maven_repo}/io/trino/trino-server/${trino_version}/${trino_server_pkg} && \
    trino_client_jar=trino-cli-${trino_version}-executable.jar && \
    trino_client_jar_url=${maven_repo}/io/trino/trino-cli/${trino_version}/${trino_client_jar} && \
    mkdir -p ${trino_module_home} && cd ${trino_module_home} && curl -LO ${trino_server_pkg_url} && \
    tar -xzvf ${trino_server_pkg} && rm ${trino_server_pkg} && mv ${trino_server_folder}/* ./ && rm -rf ${trino_server_folder} && \
    curl -LO ${trino_client_jar_url} && mv ${trino_client_jar} ./bin/trino && chmod +x ./bin/trino && \

## copy config
    mkdir -p ${trino_module_home}/etc && mkdir -p ${trino_script_home} && \
    mv /tmp/etc/* ${trino_module_home}/etc/ && rm -r /tmp/etc && \
    mv /tmp/init-trino.sh ${trino_script_home}/ && \

    sed -i "s#{trino_module_home}#${trino_module_home}#g" /usr/local/bin/trinostart && \
    sed -i "s#{trino_module_home}#${trino_module_home}#g" /usr/local/bin/trinostop && \
    sed -i "s#{trino_module_home}#${trino_module_home}#g" ${trino_script_home}/init-trino.sh && \
    chmod +x /usr/local/bin/trinostart && chmod +x /usr/local/bin/trinostop && chmod +x /usr/local/bin/trinorestart && \

## init service
    echo "sh ${trino_script_home}/init-trino.sh && trinostart" >> /init_service