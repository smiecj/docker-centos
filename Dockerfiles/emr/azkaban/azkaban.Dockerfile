# azkaban single node
ARG JAVA_IMAGE
FROM ${JAVA_IMAGE}

ARG azkaban_code_git=https://github.com/azkaban/azkaban
ARG azkaban_tag=
ARG code_home=/opt/coding
ARG module_home=/opt/modules/azkaban
ARG web_server_home=${module_home}/azkaban-web-server
ARG exec_server_home=${module_home}/azkaban-exec-server
ARG scripts_home=${module_home}/scripts
ARG sql_home=${module_home}/sql

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

# mysql client
RUN yum -y install mysql

# download code and build package
RUN source /etc/profile && mkdir -p ${code_home} && cd ${code_home} && git clone ${azkaban_code_git} && \ 
    cd azkaban && if [ "" != "$azkaban_tag" ]; then git checkout tags/${azkaban_tag}; fi && \
    ./gradlew build -x test && mkdir -p ${module_home} && \
    web_server_pkg=`ls -l azkaban-web-server/build/distributions | grep "tar.gz" | sed 's/.* //g'` && \
    web_server_folder=`echo ${web_server_pkg} | sed 's/.tar.gz//g'` && \
    exec_server_pkg=`ls -l azkaban-exec-server/build/distributions | grep "tar.gz" | sed 's/.* //g'` && \
    exec_server_folder=`echo ${exec_server_pkg} | sed 's/.tar.gz//g'` && \
    mv azkaban-web-server/build/distributions/${web_server_pkg} ${module_home} && \
    mv azkaban-exec-server/build/distributions/${exec_server_pkg} ${module_home} && \
    cd ${module_home} && tar -xzvf ${web_server_pkg} && \
    mv ${web_server_folder} azkaban-web-server && rm ${web_server_pkg} && \
    tar -xzvf ${exec_server_pkg} && mv ${exec_server_folder} azkaban-exec-server && rm ${exec_server_pkg} && \
    ## clean mvn package
    rm -rf ${HOME}/.cache && \
    rm -rf ${code_home}

# copy scripts
RUN mkdir -p ${scripts_home}
COPY ./scripts/init-web-server.sh ${scripts_home}
COPY ./scripts/init-exec-server.sh ${scripts_home}
COPY ./conf/azkaban_web_server.properties.template ${web_server_home}/conf/
COPY ./conf/azkaban_exec_server.properties.template ${exec_server_home}/conf/
RUN sed -i "s#{azkaban_web_server_home}#${web_server_home}#g" ${scripts_home}/init-web-server.sh && \
    sed -i "s#{azkaban_exec_server_home}#${exec_server_home}#g" ${scripts_home}/init-exec-server.sh

COPY ./scripts/web-server-start.sh /usr/local/bin/azkabanwebserverstart
COPY ./scripts/web-server-stop.sh /usr/local/bin/azkabanwebserverstop
COPY ./scripts/web-server-restart.sh /usr/local/bin/azkabanwebserverrestart
COPY ./scripts/exec-server-start.sh /usr/local/bin/azkabanexecserverstart
COPY ./scripts/exec-server-stop.sh /usr/local/bin/azkabanexecserverstop
COPY ./scripts/exec-server-restart.sh /usr/local/bin/azkabanexecserverrestart
COPY ./scripts/azkaban-start-all.sh /usr/local/bin/azkabanstartall
COPY ./scripts/azkaban-stop-all.sh /usr/local/bin/azkabanstopall
COPY ./scripts/azkaban-restart-all.sh /usr/local/bin/azkabanrestartall
RUN sed -i "s#{azkaban_web_server_home}#${web_server_home}#g" /usr/local/bin/azkabanwebserverstart && \
    sed -i "s#{azkaban_web_server_home}#${web_server_home}#g" /usr/local/bin/azkabanwebserverstop && \
    chmod +x /usr/local/bin/azkabanwebserverstart && chmod +x /usr/local/bin/azkabanwebserverstop && chmod +x /usr/local/bin/azkabanwebserverrestart && \
    sed -i "s#{azkaban_exec_server_home}#${exec_server_home}#g" /usr/local/bin/azkabanexecserverstart && \
    sed -i "s#{azkaban_exec_server_home}#${exec_server_home}#g" /usr/local/bin/azkabanexecserverstop && \
    chmod +x /usr/local/bin/azkabanexecserverstart && chmod +x /usr/local/bin/azkabanexecserverstop && chmod +x /usr/local/bin/azkabanexecserverrestart && \
    chmod +x /usr/local/bin/azkabanstartall && chmod +x /usr/local/bin/azkabanstopall && chmod +x /usr/local/bin/azkabanrestartall

RUN mkdir -p ${sql_home}
COPY ./sql/init-azkaban.sql ${sql_home}/
COPY ./scripts/init-db.sh ${scripts_home}/
RUN sed -i "s#{azkaban_sql_home}#${sql_home}#g" ${scripts_home}/init-db.sh

# init 
RUN echo "sh ${scripts_home}/init-db.sh && sh ${scripts_home}/init-exec-server.sh && sh ${scripts_home}/init-web-server.sh && \${AZKABAN_START}" >> /init_service