ARG IMAGE_JAVA
FROM ${IMAGE_JAVA}

# install doris
ENV PORT=3306
ENV ROOT_PASSWORD=root_Test1qaz

# self define user
ENV USER_DB ""
ENV USER_NAME ""
ENV USER_PASSWORD ""

ENV FE_HTTP_PORT=8030
ENV FE_RPC_PORT=9020
ENV FE_EDIT_PORT=9010
ENV FE_QUERY_PORT=9030
ENV FE_META_DIR=/opt/doris/meta
ENV FE_MASTER_HOST=
ENV FE_FOLLOWER_HOSTS=
ENV FE_LOG_LEVEL=INFO
ENV FE_REPLICA_ACK_POLICY=SIMPLE_MAJORITY

ENV BE_PORT=9060
ENV BE_HEARTBEAT_PORT=9050
ENV BE_BRPC_PORT=8060
ENV BE_HTTP_PORT=8040
ENV BE_STORAGE_PATH=/opt/doris/data
ENV BE_HOSTS=127.0.0.1
ENV BE_LOG_LEVEL=INFO

ENV DORIS_START=dorisstartall

ARG doris_version
ARG doris_repo
ARG module_home

# scripts & config
COPY ./conf_be /tmp/conf_be
COPY ./conf_fe /tmp/conf_fe

COPY ./scripts/ /tmp

ARG TARGETARCH

RUN mv /tmp/init-doris-account.sh /usr/local/bin/dorisaccountinit && \
    mv /tmp/doris-connect.sh /usr/local/bin/dorisconnect && \
    mv /tmp/doris-fe-start.sh /usr/local/bin/dorisfestart && \
    mv /tmp/doris-fe-stop.sh /usr/local/bin/dorisfestop && \
    mv /tmp/doris-fe-restart.sh /usr/local/bin/dorisferestart && \
    mv /tmp/doris-be-start.sh /usr/local/bin/dorisbestart && \
    mv /tmp/doris-be-stop.sh /usr/local/bin/dorisbestop && \
    mv /tmp/doris-be-restart.sh /usr/local/bin/dorisberestart && \
    mv /tmp/doris-start-all.sh /usr/local/bin/dorisstartall && \
    mv /tmp/doris-stop-all.sh /usr/local/bin/dorisstopall && \
    mv /tmp/doris-restart-all.sh /usr/local/bin/dorisrestartall && \
    mv /tmp/doris-not-start.sh /usr/local/bin/dorisnotstart && \
    mv /tmp/doris-fe-log.sh /usr/local/bin/dorisfelog && \
    mv /tmp/doris-be-log.sh /usr/local/bin/dorisbelog && \

    if [ "arm64" == "$TARGETARCH" ]; \
    then\
        arch="arm64";\
    else\
        arch="x64-noavx2";\
    fi && \

## install
    doris_module_home=${module_home}/doris && \
    doris_be_module_home=${doris_module_home}/be && \
    doris_fe_module_home=${doris_module_home}/fe && \
    doris_script_home=${doris_module_home}/scripts && \
    doris_folder=apache-doris-${doris_version}-bin-${arch} && \
    doris_pkg=${doris_folder}.tar.gz && \
    doris_pkg_url=${doris_repo}/${doris_pkg} && \

    ## mysql client
    yum -y install mysql && \
    mkdir -p ${doris_module_home} && mkdir -p ${doris_script_home} && \
    cd ${doris_module_home} && curl -LO ${doris_pkg_url} && \
    tar -xzvf ${doris_pkg} && rm ${doris_pkg} && mv ${doris_folder}/* ./ && rm -r ${doris_folder} && \

## config
    cp /tmp/conf_be/* ${doris_be_module_home}/conf/ && \
    cp /tmp/conf_fe/* ${doris_fe_module_home}/conf/ && \
    rm -r /tmp/conf_be && rm -r /tmp/conf_fe && \
    mv /tmp/init-doris.sh ${doris_script_home}/ && \

## meta & storage
    mkdir -p ${doris_fe_module_home}/meta && \
    mkdir -p ${doris_be_module_home}/storage && \

## scripts
    sed -i "s#{doris_fe_module_home}#${doris_fe_module_home}#g" /usr/local/bin/doris* && \
    sed -i "s#{doris_be_module_home}#${doris_be_module_home}#g" /usr/local/bin/doris* && \
    sed -i "s#{doris_fe_module_home}#${doris_fe_module_home}#g" ${doris_script_home}/init-doris.sh && \
    sed -i "s#{doris_be_module_home}#${doris_be_module_home}#g" ${doris_script_home}/init-doris.sh && \
    chmod +x /usr/local/bin/doris* && \

## init service
    echo "sh ${doris_script_home}/init-doris.sh && \${DORIS_START}" >> /init_service