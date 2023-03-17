# azkaban single node
ARG IMAGE_JAVA
FROM ${IMAGE_JAVA}

ARG module_home
ARG github_url

ARG dolphinscheduler_version

# scripts
COPY ./scripts/web-server-start.sh /usr/local/bin/azkabanwebserverstart
COPY ./scripts/web-server-stop.sh /usr/local/bin/azkabanwebserverstop
COPY ./scripts/web-server-restart.sh /usr/local/bin/azkabanwebserverrestart
COPY ./scripts/init-web-server.sh /tmp
COPY ./scripts/init-exec-server.sh /tmp
COPY ./scripts/init-db.sh /tmp
COPY ./sql/init-azkaban.sql /tmp
COPY ./conf/azkaban_web_server.properties.template /tmp
COPY ./conf/azkaban_exec_server.properties.template /tmp

# compile
RUN dolphinscheduler_pkg_folder=apache-dolphinscheduler-${dolphinscheduler_version}-bin && \
    dolphinscheduler_pkg=${dolphinscheduler_pkg_folder}.tar.gz && \
    dolphinscheduler_module_home=${module_home}/dolphinscheduler && \
    cd /tmp && git clone ${github_url}/apache/dolphinscheduler && \
    
    cd dolphinscheduler && git checkout tags/${dolphinscheduler_version} && \
    # mvn clean install -DskipTests -Prelease -pl "dolphinscheduler-ui" && \
    # mvn clean package -DskipTests -Prelease -pl "!dolphinscheduler-ui" && \
    mvn clean package -DskipTests -Prelease && \

    mkdir -p ${dolphinscheduler_module_home} && \
    mv ./dolphinscheduler-dist/target/${dolphinscheduler_pkg} ${dolphinscheduler_module_home} && \
    rm -r /tmp/${dolphinscheduler_code_folder} && rm -rf ~/.m2/repository/* && \
    
    cd ${dolphinscheduler_module_home} && tar -xzvf ${dolphinscheduler_pkg} && \
    mv ${dolphinscheduler_pkg_folder}/* ./ && rm -r ${dolphinscheduler_pkg_folder} && \
    
    sed -i "s#{dolphinscheduler_module_home}#${dolphinscheduler_module_home}#g" /usr/local/bin/dolphinschedulerstart && \
    sed -i "s#{dolphinscheduler_module_home}#${dolphinscheduler_module_home}#g" /usr/local/bin/dolphinschedulerstop && \
    chmod +x /usr/local/bin/dolphinschedulerstart && chmod +x /usr/local/bin/dolphinschedulerstop && chmod +x /usr/local/bin/dolphinschedulerrestart && \
# init 
    echo "dolphinschedulerstart" >> /init_service