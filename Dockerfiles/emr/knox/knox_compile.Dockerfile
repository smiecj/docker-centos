ARG JAVA_IMAGE
FROM ${JAVA_IMAGE}

ARG tag=1.6.1
ARG knox_repo=https://mirrors.aliyun.com/apache/knox
ARG knox_pkg_url=${knox_repo}/${tag}/knox-${tag}.zip
ARG knox_source_url=${knox_repo}/${tag}/knox-${tag}-src.zip
ARG knox_source_pkg=knox-${tag}-src.zip
ARG knox_source_folder=knox-${tag}

ARG knox_pkg=knox-${tag}.tar.gz
ARG knox_module_home=/opt/modules/knox
ARG knox_module_folder=knox-${tag}
ARG knox_scripts_home=${knox_module_home}/scripts

ENV KNOX_PORT 8443
ENV WEBHDFS_ADDRESS localhost:50070
ENV YARN_ADDRESS localhost:8088

# compile
## tag >= 2.0: pkg: ./target; tag < 2.0: pkg: ./candidate
RUN mkdir -p ${knox_module_home}
RUN source /etc/profile && cd /tmp && curl -LO ${knox_source_url} && unzip ${knox_source_pkg} && rm ${knox_source_pkg} && \
    cd ${knox_source_folder} && \
    sed -i "s#<excludeSubProjects>false</excludeSubProjects>#\n<skip>true</skip>\n<excludeSubProjects>false</excludeSubProjects>#g" pom.xml && \
    sed -i "s#<excludedGroups>#\n<skipTests>true</skipTests>\n<excludedGroups>#g" pom.xml && \
    ant release -Drat.skip=true -Dmaven.test.skip=true -DskipTests=true && \
    knox_actual_pkg=`ls -l ./candidate | grep "knox-.*tar.gz$" | sed 's/.* //g'` && \
    knox_actual_folder=`echo $knox_actual_pkg | sed 's/.tar.gz//g'` && \
    cp ./candidate/${knox_actual_pkg} ${knox_module_home}/${knox_pkg} && cd ${knox_module_home} && tar -xzvf ${knox_pkg} && \
    mv ${knox_actual_folder} ${knox_module_folder} && rm ${knox_pkg} && mv ${knox_module_folder}/* ./ && rm -rf ${knox_module_folder} && \
    rm -rf /tmp/${knox_source_folder}

# scripts
RUN mkdir -p ${knox_scripts_home}
COPY ./scripts/init-knox.sh ${knox_scripts_home}/
COPY ./scripts/knox-start.sh /usr/local/bin/knoxstart
COPY ./scripts/knox-stop.sh /usr/local/bin/knoxstop
COPY ./scripts/knox-restart.sh /usr/local/bin/knoxrestart
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
