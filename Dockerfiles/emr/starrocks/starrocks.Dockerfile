ARG IMAGE_JAVA
FROM ${IMAGE_JAVA}

# install starrocks
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
ENV FE_META_DIR=/opt/starrocks/meta

ENV BE_PORT=9060
ENV BE_HEARTBEAT_PORT=9050
ENV BE_BRPC_PORT=8060
ENV BE_HTTP_PORT=8040
ENV BE_STORAGE_PATH=/opt/starrocks/data
ENV BE_HOSTS=127.0.0.1

ENV FE_MASTER_HOST=
ENV FE_FOLLOWER_HOSTS=

ENV STARROCKS_START=starrocksstartall

ARG starrocks_version
ARG module_home

# scripts & config
COPY ./conf_be /tmp/conf_be
COPY ./conf_fe /tmp/conf_fe
COPY ./scripts/init-starrocks.sh /tmp
COPY ./scripts/init-starrocks-account.sh /usr/local/bin/starrocksaccountinit
COPY ./scripts/starrocks-connect.sh /usr/local/bin/starrocksconnect
COPY ./scripts/starrocks-fe-start.sh /usr/local/bin/starrocksfestart
COPY ./scripts/starrocks-fe-stop.sh /usr/local/bin/starrocksfestop
COPY ./scripts/starrocks-fe-restart.sh /usr/local/bin/starrocksferestart
COPY ./scripts/starrocks-be-start.sh /usr/local/bin/starrocksbestart
COPY ./scripts/starrocks-be-stop.sh /usr/local/bin/starrocksbestop
COPY ./scripts/starrocks-be-restart.sh /usr/local/bin/starrocksberestart
COPY ./scripts/starrocks-start-all.sh /usr/local/bin/starrocksstartall
COPY ./scripts/starrocks-stop-all.sh /usr/local/bin/starrocksstopall
COPY ./scripts/starrocks-restart-all.sh /usr/local/bin/starrocksrestartall
COPY ./scripts/starrocks-not-start.sh /usr/local/bin/starrocksnotstart
COPY ./scripts/starrocks-fe-log.sh /usr/local/bin/starrocksfelog
COPY ./scripts/starrocks-be-log.sh /usr/local/bin/starrocksbelog

## install
RUN starrocks_module_home=${module_home}/starrocks && \
    starrocks_be_module_home=${starrocks_module_home}/be && \
    starrocks_fe_module_home=${starrocks_module_home}/fe && \
    starrocks_script_home=${starrocks_module_home}/scripts && \
    starrocks_folder=StarRocks-${starrocks_version} && \
    starrocks_pkg=${starrocks_folder}.tar.gz && \
    starrocks_pkg_url=https://releases.starrocks.io/starrocks/${starrocks_pkg} && \

    ## mysql client
    yum -y install mysql && \
    mkdir -p ${starrocks_module_home} && mkdir -p ${starrocks_script_home} && \
    cd ${starrocks_module_home} && curl -LO ${starrocks_pkg_url} && \
    tar -xzvf ${starrocks_pkg} && rm ${starrocks_pkg} && mv ${starrocks_folder}/* ./ && rm -r ${starrocks_folder} && \

## config
    cp /tmp/conf_be/* ${starrocks_be_module_home}/conf/ && \
    cp /tmp/conf_fe/* ${starrocks_fe_module_home}/conf/ && \
    rm -r /tmp/conf_be && rm -r /tmp/conf_fe && \
    mv /tmp/init-starrocks.sh ${starrocks_script_home}/ && \

## meta & storage
    mkdir -p ${starrocks_fe_module_home}/meta && \
    mkdir -p ${starrocks_be_module_home}/storage && \

## scripts
    sed -i "s#{starrocks_fe_module_home}#${starrocks_fe_module_home}#g" /usr/local/bin/starrocksfestart && \
    sed -i "s#{starrocks_fe_module_home}#${starrocks_fe_module_home}#g" /usr/local/bin/starrocksfestop && \
    sed -i "s#{starrocks_be_module_home}#${starrocks_be_module_home}#g" /usr/local/bin/starrocksbestart && \
    sed -i "s#{starrocks_be_module_home}#${starrocks_be_module_home}#g" /usr/local/bin/starrocksbestop && \
    sed -i "s#{starrocks_fe_module_home}#${starrocks_fe_module_home}#g" /usr/local/bin/starrocksfelog && \
    sed -i "s#{starrocks_be_module_home}#${starrocks_be_module_home}#g" /usr/local/bin/starrocksbelog && \
    sed -i "s#{starrocks_fe_module_home}#${starrocks_fe_module_home}#g" ${starrocks_script_home}/init-starrocks.sh && \
    sed -i "s#{starrocks_be_module_home}#${starrocks_be_module_home}#g" ${starrocks_script_home}/init-starrocks.sh && \
    chmod +x /usr/local/bin/starrocksfestart && chmod +x /usr/local/bin/starrocksfestop && chmod +x /usr/local/bin/starrocksferestart && \
    chmod +x /usr/local/bin/starrocksbestart && chmod +x /usr/local/bin/starrocksbestop && chmod +x /usr/local/bin/starrocksberestart && \
    chmod +x /usr/local/bin/starrocksstartall && chmod +x /usr/local/bin/starrocksstopall && chmod +x /usr/local/bin/starrocksrestartall && chmod +x /usr/local/bin/starrocksnotstart && \
    chmod +x /usr/local/bin/starrocksfelog && chmod +x /usr/local/bin/starrocksbelog && \
    chmod +x /usr/local/bin/starrocksaccountinit && chmod +x /usr/local/bin/starrocksconnect && \

## init service
    echo "sh ${starrocks_script_home}/init-starrocks.sh && \${STARROCKS_START}" >> /init_service