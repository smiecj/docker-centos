ARG IMAGE_JAVA
FROM ${IMAGE_JAVA}

ARG apache_repo
ARG knox_version
ARG module_home

ENV KNOX_PORT 8443
ENV WEBHDFS_ADDRESS localhost:50070
ENV YARN_ADDRESS localhost:8088

# scripts
COPY ./scripts/init-knox.sh /tmp
COPY ./scripts/knox-start.sh /usr/local/bin/knoxstart
COPY ./scripts/knox-stop.sh /usr/local/bin/knoxstop
COPY ./scripts/knox-restart.sh /usr/local/bin/knoxrestart
COPY ./scripts/knox-not-start.sh /usr/local/bin/knoxnotstarts

# config
## gateway-site.xml
COPY ./conf/gateway-site_template.xml /tmp
## sandbox
COPY ./conf/topologies/sandbox_template.xml /tmp
## hdfsui rewrite
COPY ./data/services/hdfsui/2.7.0/rewrite.xml /tmp

# install
RUN knox_module_home=${module_home}/knox && \
    knox_module_folder=knox-${knox_version} && \
    knox_scripts_home=${knox_module_home}/scripts && \
    mkdir -p ${knox_scripts_home} && \
    knox_repo=${apache_repo}/knox && \
    knox_pkg_url=${knox_repo}/${knox_version}/knox-${knox_version}.zip && \
    knox_pkg=knox-${knox_version}.zip && \
    mkdir -p ${knox_module_home} && cd ${knox_module_home} && curl -LOk ${knox_pkg_url} && \
    unzip ${knox_pkg} && rm ${knox_pkg} && mv ${knox_module_folder}/* ./ && rm -rf ${knox_module_folder} && \

    chmod +x /usr/local/bin/knox* && \
    mv /tmp/init-knox.sh ${knox_scripts_home}/ && \
    sed -i "s#{knox_module_home}#${knox_module_home}#g" ${knox_scripts_home}/init-knox.sh && \
    sed -i "s#{knox_module_home}#${knox_module_home}#g" /usr/local/bin/knoxstart && \
    echo "sh ${knox_scripts_home}/init-knox.sh && knoxstart" >> /init_service && \

## gateway.sh: allow root user
    gateway_script=${knox_module_home}/bin/gateway.sh && \
    sed -i "s/function checkEnv {/function checkEnv {\n<<COMMENT/g" $gateway_script && \
    sed -i "s/    checkWriteDir \"\$APP_LOG_DIR\"/COMMENT\n    checkWriteDir \"\$APP_LOG_DIR\"/g" $gateway_script && \

## config
    mv /tmp/gateway-site_template.xml ${knox_module_home}/conf && \
    mv /tmp/sandbox_template.xml ${knox_module_home}/conf/topologies/ && \
    mv /tmp/rewrite.xml ${knox_module_home}/data/services/hdfsui/2.7.0/