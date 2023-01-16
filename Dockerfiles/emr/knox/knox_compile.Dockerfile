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

## gateway-site.xml
COPY ./conf/gateway-site_template.xml /tmp
## sandbox
COPY ./conf/topologies/sandbox_template.xml /tmp
## hdfsui rewrite
COPY ./data/services/hdfsui/2.7.0/rewrite.xml /tmp

# compile
## tag >= 2.0: pkg: ./target; tag < 2.0: pkg: ./candidate
RUN knox_pkg=knox-${knox_version}.tar.gz && \
    knox_module_home=${module_home}/knox && \
    knox_module_folder=knox-${knox_version} && \
    knox_scripts_home=${knox_module_home}/scripts && \
    knox_repo=${apache_repo}/knox && \
    knox_pkg_url=${knox_repo}/${knox_version}/knox-${knox_version}.zip && \
    knox_source_url=${knox_repo}/${knox_version}/knox-${knox_version}-src.zip && \
    knox_source_pkg=knox-${knox_version}-src.zip && \
    knox_source_folder=knox-${knox_version} && \
    mkdir -p ${knox_module_home} && \
    mkdir -p ${knox_scripts_home} && \
    source /etc/profile && cd /tmp && curl -LO ${knox_source_url} && unzip ${knox_source_pkg} && rm ${knox_source_pkg} && \
    cd ${knox_source_folder} && \
    sed -i "s#<excludeSubProjects>false</excludeSubProjects>#\n<skip>true</skip>\n<excludeSubProjects>false</excludeSubProjects>#g" pom.xml && \
    sed -i "s#<excludedGroups>#\n<skipTests>true</skipTests>\n<excludedGroups>#g" pom.xml && \
    ant release -Drat.skip=true -Dmaven.test.skip=true -DskipTests=true && \
    knox_actual_pkg=`ls -l ./candidate | grep "knox-.*tar.gz$" | sed 's/.* //g'` && \
    knox_actual_folder=`echo $knox_actual_pkg | sed 's/.tar.gz//g'` && \
    cp ./candidate/${knox_actual_pkg} ${knox_module_home}/${knox_pkg} && cd ${knox_module_home} && tar -xzvf ${knox_pkg} && \
    mv ${knox_actual_folder} ${knox_module_folder} && rm ${knox_pkg} && mv ${knox_module_folder}/* ./ && rm -rf ${knox_module_folder} && \
    rm -rf /tmp/${knox_source_folder} && \
    rm -rf ~/.m2/repository/* && \

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
