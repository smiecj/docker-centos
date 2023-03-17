# azkaban single node
ARG IMAGE_JAVA
FROM ${IMAGE_JAVA}

ARG module_home
ARG github_url

## env: mysql
ENV MYSQL_HOST=localhost
ENV MYSQL_PORT=3306
ENV MYSQL_DB=azkaban
ENV MYSQL_USER=azkaban
ENV MYSQL_PASSWORD=azkaban123

## env: azkaban
ENV WEB_SERVER_HOST=localhost
ENV WEB_SERVER_PORT=8020
ENV EXEC_SERVER_PORT=8030
### start command: azkabanstartall / azkabanwebserverstart / azkabanexecserverstart
ENV AZKABAN_START=azkabanstartall

ENV ADMIN_USER=azkaban
ENV ADMIN_PASSWORD=azkaban

# scripts
COPY ./scripts/web-server-start.sh /usr/local/bin/azkabanwebserverstart
COPY ./scripts/web-server-stop.sh /usr/local/bin/azkabanwebserverstop
COPY ./scripts/web-server-restart.sh /usr/local/bin/azkabanwebserverrestart
COPY ./scripts/exec-server-start.sh /usr/local/bin/azkabanexecserverstart
COPY ./scripts/exec-server-stop.sh /usr/local/bin/azkabanexecserverstop
COPY ./scripts/exec-server-restart.sh /usr/local/bin/azkabanexecserverrestart
COPY ./scripts/azkaban-start-all.sh /usr/local/bin/azkabanstartall
COPY ./scripts/azkaban-stop-all.sh /usr/local/bin/azkabanstopall
COPY ./scripts/azkaban-restart-all.sh /usr/local/bin/azkabanrestartall

COPY ./scripts/init-web-server.sh /tmp
COPY ./scripts/init-exec-server.sh /tmp
COPY ./scripts/init-db.sh /tmp
COPY ./sql/init-azkaban.sql /tmp
COPY ./conf/azkaban_web_server.properties.template /tmp
COPY ./conf/azkaban_exec_server.properties.template /tmp
COPY ./conf/azkaban-users.xml.template /tmp

# mysql client
RUN yum -y install mysql && \

# download code and build package
    azkaban_module_home=${module_home}/azkaban && \
    web_server_home=${azkaban_module_home}/azkaban-web-server && \
    exec_server_home=${azkaban_module_home}/azkaban-exec-server && \
    scripts_home=${azkaban_module_home}/scripts && \
    sql_home=${azkaban_module_home}/sql && \
    azkaban_code_git=${github_url}/azkaban/azkaban && \
    code_home=/tmp && \

    source /etc/profile && mkdir -p ${code_home} && cd ${code_home} && git clone ${azkaban_code_git} && \ 
    cd azkaban && ./gradlew build -x test && \
    mkdir -p ${azkaban_module_home} && \
    web_server_pkg=`ls -l azkaban-web-server/build/distributions | grep "tar.gz" | sed 's/.* //g'` && \
    web_server_folder=`echo ${web_server_pkg} | sed 's/.tar.gz//g'` && \
    exec_server_pkg=`ls -l azkaban-exec-server/build/distributions | grep "tar.gz" | sed 's/.* //g'` && \
    exec_server_folder=`echo ${exec_server_pkg} | sed 's/.tar.gz//g'` && \
    mv azkaban-web-server/build/distributions/${web_server_pkg} ${azkaban_module_home} && \
    mv azkaban-exec-server/build/distributions/${exec_server_pkg} ${azkaban_module_home} && \
    cd ${azkaban_module_home} && tar -xzvf ${web_server_pkg} && \
    mv ${web_server_folder} azkaban-web-server && rm ${web_server_pkg} && \
    tar -xzvf ${exec_server_pkg} && mv ${exec_server_folder} azkaban-exec-server && rm ${exec_server_pkg} && \
    ## clean gradle package
    rm -rf ${HOME}/.cache && \
    rm -rf ${code_home}/azkaban && \

# copy scripts and configs
    mkdir -p ${scripts_home} && mkdir -p ${sql_home} && \
    mv /tmp/init-db.sh ${scripts_home} && \
    mv /tmp/init-web-server.sh ${scripts_home} && \
    mv /tmp/init-exec-server.sh ${scripts_home} && \
    mv /tmp/azkaban_web_server.properties.template ${web_server_home}/conf/ && \
    mv /tmp/azkaban-users.xml.template ${web_server_home}/conf/ && \
    mv /tmp/azkaban_exec_server.properties.template ${exec_server_home}/conf/ && \
    mv /tmp/init-azkaban.sql ${sql_home} && \

    sed -i "s#{azkaban_web_server_home}#${web_server_home}#g" ${scripts_home}/init-web-server.sh && \
    sed -i "s#{azkaban_exec_server_home}#${exec_server_home}#g" ${scripts_home}/init-exec-server.sh && \

    sed -i "s#{azkaban_web_server_home}#${web_server_home}#g" /usr/local/bin/azkabanwebserverstart && \
    sed -i "s#{azkaban_web_server_home}#${web_server_home}#g" /usr/local/bin/azkabanwebserverstop && \
    chmod +x /usr/local/bin/azkabanwebserverstart && chmod +x /usr/local/bin/azkabanwebserverstop && chmod +x /usr/local/bin/azkabanwebserverrestart && \
    sed -i "s#{azkaban_exec_server_home}#${exec_server_home}#g" /usr/local/bin/azkabanexecserverstart && \
    sed -i "s#{azkaban_exec_server_home}#${exec_server_home}#g" /usr/local/bin/azkabanexecserverstop && \
    chmod +x /usr/local/bin/azkabanexecserverstart && chmod +x /usr/local/bin/azkabanexecserverstop && chmod +x /usr/local/bin/azkabanexecserverrestart && \
    chmod +x /usr/local/bin/azkabanstartall && chmod +x /usr/local/bin/azkabanstopall && chmod +x /usr/local/bin/azkabanrestartall && \

    sed -i "s#{azkaban_sql_home}#${sql_home}#g" ${scripts_home}/init-db.sh && \
# init 
    echo "sh ${scripts_home}/init-db.sh && sh ${scripts_home}/init-exec-server.sh && sh ${scripts_home}/init-web-server.sh && \${AZKABAN_START}" >> /init_service && \

## fix: org/apache/hadoop/conf/Configuration not found
    cp ${exec_server_home}/lib/hadoop-common*.jar ${web_server_home}/lib/