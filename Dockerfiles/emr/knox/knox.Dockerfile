ARG JAVA_IMAGE
FROM ${JAVA_IMAGE}

ARG tag=1.6.1
# ARG knox_repo=https://dlcdn.apache.org/knox
# ARG knox_repo=https://mirrors.sdwu.edu.cn/apache/knox
ARG knox_repo=https://mirrors.aliyun.com/apache/knox
ARG knox_pkg_url=${knox_repo}/${tag}/knox-${tag}.zip
ARG knox_pkg=knox-${tag}.zip
ARG knox_module_home=/opt/modules/knox
ARG knox_module_folder=knox-${tag}
ARG knox_scripts_home=${knox_module_home}/scripts

ENV KNOX_PORT 8443
ENV WEBHDFS_ADDRESS localhost:50070
ENV YARN_ADDRESS localhost:8088

# install
RUN mkdir -p ${knox_module_home} && cd ${knox_module_home} && curl -LOk ${knox_pkg_url} && \
    unzip ${knox_pkg} && rm ${knox_pkg} && mv ${knox_module_folder}/* ./ && rm -rf ${knox_module_folder}

# scripts
RUN mkdir -p ${knox_scripts_home}
COPY ./scripts/init-knox.sh ${knox_scripts_home}/
COPY ./scripts/knox-start.sh /usr/local/bin/knoxstart
COPY ./scripts/knox-stop.sh /usr/local/bin/knoxstop
COPY ./scripts/knox-restart.sh /usr/local/bin/knoxrestart
COPY ./scripts/knox-not-start.sh /usr/local/bin/knoxnotstart
RUN chmod +x /usr/local/bin/knox*

RUN sed -i "s#{knox_module_home}#${knox_module_home}#g" ${knox_scripts_home}/init-knox.sh

RUN sed -i "s#{knox_module_home}#${knox_module_home}#g" /usr/local/bin/knoxstart

RUN echo "sh ${knox_scripts_home}/init-knox.sh && knoxstart" >> /init_service

# config

## gateway-site.xml
COPY ./conf/gateway-site_template.xml ${knox_module_home}/conf

## sandbox
COPY ./conf/topologies/sandbox_template.xml ${knox_module_home}/conf/topologies/sandbox_template.xml

## hdfsui rewrite
COPY ./data/services/hdfsui/2.7.0/rewrite.xml ${knox_module_home}/data/services/hdfsui/2.7.0/

## gateway.sh: allow root user
RUN gateway_script=${knox_module_home}/bin/gateway.sh && \
    sed -i "s/function checkEnv {/function checkEnv {\n<<COMMENT/g" $gateway_script && \
    sed -i "s/    checkWriteDir \"\$APP_LOG_DIR\"/COMMENT\n    checkWriteDir \"\$APP_LOG_DIR\"/g" $gateway_script
