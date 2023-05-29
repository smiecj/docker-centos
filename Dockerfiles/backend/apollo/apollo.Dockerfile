ARG IMAGE_JAVA
FROM ${IMAGE_JAVA} AS java_base

ARG apollo_version
ARG github_url
ARG module_home

ENV MYSQL_HOST=localhost
ENV MYSQL_PORT=3306
ENV MYSQL_USER=root
ENV MYSQL_PASSWORD=pwd

ENV portal_port=8070
ENV configservice_port=8080
ENV adminservice_port=8090

COPY scripts/init-apollo.sh /tmp/
COPY scripts/init-db.sh /tmp/

COPY ./scripts/apollo-adminservice-start.sh /usr/local/bin/apolloadminservicestart
COPY ./scripts/apollo-adminservice-stop.sh /usr/local/bin/apolloadminservicestop
COPY ./scripts/apollo-adminservice-restart.sh /usr/local/bin/apolloadminservicerestart
COPY ./scripts/apollo-adminservice-log.sh /usr/local/bin/apolloadminservicelog

COPY ./scripts/apollo-configservice-start.sh /usr/local/bin/apolloconfigservicestart
COPY ./scripts/apollo-configservice-stop.sh /usr/local/bin/apolloconfigservicestop
COPY ./scripts/apollo-configservice-restart.sh /usr/local/bin/apolloconfigservicerestart
COPY ./scripts/apollo-configservice-log.sh /usr/local/bin/apolloconfigservicelog

COPY ./scripts/apollo-portal-start.sh /usr/local/bin/apolloportalstart
COPY ./scripts/apollo-portal-stop.sh /usr/local/bin/apolloportalstop
COPY ./scripts/apollo-portal-restart.sh /usr/local/bin/apolloportalrestart
COPY ./scripts/apollo-portal-log.sh /usr/local/bin/apolloportallog

COPY ./scripts/apollo-start-all.sh /usr/local/bin/apollostartall
COPY ./scripts/apollo-stop-all.sh /usr/local/bin/apollostopall
COPY ./scripts/apollo-restart-all.sh /usr/local/bin/apollorestartall

# mysql client
RUN yum -y install mysql && \

# download code and build package
    apollo_module_home=${module_home}/apollo && \
    apollo_sql_home=${apollo_module_home}/sql && \
    apollo_scripts_home=${apollo_module_home}/scripts && \
    apollo_configservice_home=${apollo_module_home}/configservice && \
    apollo_portal_home=${apollo_module_home}/portal && \
    apollo_adminservice_home=${apollo_module_home}/adminservice && \
    apollo_configservice_pkg=apollo-configservice-${apollo_version}-github.zip && \
    apollo_portal_pkg=apollo-portal-${apollo_version}-github.zip && \
    apollo_adminservice_pkg=apollo-adminservice-${apollo_version}-github.zip && \
    cd /tmp && git clone ${github_url}/apolloconfig/apollo && cd apollo && git checkout tags/v${apollo_version} && \
    source /etc/profile && ./mvnw clean package -pl apollo-assembly -am -DskipTests=true && \
    mkdir -p ${apollo_module_home} && mkdir -p ${apollo_sql_home} && \
    cp ./scripts/sql/apolloportaldb.sql ${apollo_sql_home} && \
    cp ./scripts/sql/apolloconfigdb.sql ${apollo_sql_home} && \
    mkdir -p ${apollo_configservice_home} && mkdir -p ${apollo_portal_home} && mkdir -p ${apollo_adminservice_home} && \
    cp apollo-configservice/target/${apollo_configservice_pkg} ${apollo_configservice_home} && \
    cp apollo-portal/target/${apollo_portal_pkg} ${apollo_portal_home} && \
    cp apollo-adminservice/target/${apollo_adminservice_pkg} ${apollo_adminservice_home} && \
    rm -r /tmp/apollo && rm -rf ~/.m2/repository/* && \
    cd ${apollo_configservice_home} && unzip ${apollo_configservice_pkg} && rm ${apollo_configservice_pkg} && \
    sed -i "s#LOG_DIR=.*#LOG_DIR=${apollo_configservice_home}/log#g" scripts/startup.sh && \
    sed -i "s#mkdir -p \$LOG_DIR#mkdir -p \$LOG_DIR\nexport JAVA_OPTS=\"\$JAVA_OPTS -Dspring.config.additional-location=${apollo_configservice_home}/config/application-github.properties\"#g" scripts/startup.sh && \
    cd ${apollo_portal_home} && unzip ${apollo_portal_pkg} && rm ${apollo_portal_pkg} && \
    sed -i "s#LOG_DIR=.*#LOG_DIR=${apollo_portal_home}/log#g" scripts/startup.sh && \
    sed -i "s#mkdir -p \$LOG_DIR#mkdir -p \$LOG_DIR\nexport JAVA_OPTS=\"\$JAVA_OPTS -Dspring.config.additional-location=${apollo_portal_home}/config/application-github.properties\"#g" scripts/startup.sh && \
    cd ${apollo_adminservice_home} && unzip ${apollo_adminservice_pkg} && rm ${apollo_adminservice_pkg} && \
    sed -i "s#LOG_DIR=.*#LOG_DIR=${apollo_adminservice_home}/log#g" scripts/startup.sh && \
    sed -i "s#mkdir -p \$LOG_DIR#mkdir -p \$LOG_DIR\nexport JAVA_OPTS=\"\$JAVA_OPTS -Dspring.config.additional-location=${apollo_adminservice_home}/config/application-github.properties\"#g" scripts/startup.sh && \

# scripts
    mkdir -p ${apollo_scripts_home} && \
    mv /tmp/init-apollo.sh ${apollo_scripts_home} && mv /tmp/init-db.sh ${apollo_scripts_home} && \

    sed -i "s#{apollo_adminservice_home}#${apollo_adminservice_home}#g" /usr/local/bin/apolloadminservicestart && \
    sed -i "s#{apollo_adminservice_home}#${apollo_adminservice_home}#g" /usr/local/bin/apolloadminservicestop && \
    sed -i "s#{apollo_adminservice_home}#${apollo_adminservice_home}#g" /usr/local/bin/apolloadminservicelog && \
    chmod +x /usr/local/bin/apolloadminservicestart && chmod +x /usr/local/bin/apolloadminservicestop && chmod +x /usr/local/bin/apolloadminservicerestart && chmod +x /usr/local/bin/apolloadminservicelog && \
    sed -i "s#{apollo_configservice_home}#${apollo_configservice_home}#g" /usr/local/bin/apolloconfigservicestart && \
    sed -i "s#{apollo_configservice_home}#${apollo_configservice_home}#g" /usr/local/bin/apolloconfigservicestop && \
    sed -i "s#{apollo_configservice_home}#${apollo_configservice_home}#g" /usr/local/bin/apolloconfigservicelog && \
    chmod +x /usr/local/bin/apolloconfigservicestart && chmod +x /usr/local/bin/apolloconfigservicestop && chmod +x /usr/local/bin/apolloconfigservicerestart && chmod +x /usr/local/bin/apolloconfigservicelog && \
    sed -i "s#{apollo_portal_home}#${apollo_portal_home}#g" /usr/local/bin/apolloportalstart && \
    sed -i "s#{apollo_portal_home}#${apollo_portal_home}#g" /usr/local/bin/apolloportalstop && \
    sed -i "s#{apollo_portal_home}#${apollo_portal_home}#g" /usr/local/bin/apolloportallog && \
    chmod +x /usr/local/bin/apolloportalstart && chmod +x /usr/local/bin/apolloportalstop && chmod +x /usr/local/bin/apolloportalrestart && chmod +x /usr/local/bin/apolloportallog && \

    chmod +x /usr/local/bin/apollostartall && chmod +x /usr/local/bin/apollostopall && chmod +x /usr/local/bin/apollorestartall && \

    sed -i "s#{apollo_adminservice_home}#${apollo_adminservice_home}#g" ${apollo_scripts_home}/init-apollo.sh && \
    sed -i "s#{apollo_configservice_home}#${apollo_configservice_home}#g" ${apollo_scripts_home}/init-apollo.sh && \
    sed -i "s#{apollo_portal_home}#${apollo_portal_home}#g" ${apollo_scripts_home}/init-apollo.sh && \
    sed -i "s#{apollo_sql_home}#${apollo_sql_home}#g" ${apollo_scripts_home}/init-db.sh && \

    echo "sh ${apollo_scripts_home}/init-db.sh && sh ${apollo_scripts_home}/init-apollo.sh && apollostartall" >> /init_service