ARG JAVA_IMAGE
FROM ${JAVA_IMAGE}

ARG repo_home=/home/repo
ARG java_repo_home=${repo_home}/java

ARG github_repo=https://github.com
# ARG datalink_git=${github_repo}/ucarGroup/DataLink
ARG datalink_git=${github_repo}/smiecj/DataLink
ARG branch=dev_bugfix
ARG datalink_modules_home=/opt/modules/datalink
ARG datalink_manager_home=${datalink_modules_home}/manager
ARG datalink_manager_scripts_home=${datalink_manager_home}/scripts
ARG datalink_worker_home=${datalink_modules_home}/worker
ARG datalink_worker_scripts_home=${datalink_worker_home}/scripts
ARG cloudera_download_url_ip=

## env: mysql
ENV MYSQL_HOST=localhost
ENV MYSQL_PORT=3306
ENV MYSQL_DB=datalink
ENV MYSQL_USER=datalink
ENV MYSQL_PASSWORD=datalink123

## env: zk
ENV ZOOKEEPER_ADDRESS=localhost:2181

## env: manager
ENV MANAGER_NETTY_PORT=8898
ENV MANAGER_HTTP_PORT=8080

## env: worker
ENV MANAGER_NETTY_ADDRESS=localhost:8898

## env: start method
ENV DATALINK_START=datalinkmanagerstart

# mysql command
RUN yum -y install mysql

# download code and build package
## install ImpalaJDBC41.jar
RUN if [ -n "${cloudera_download_url_ip}" ]; then echo "${cloudera_download_url_ip} downloads.cloudera.com" | tee -a /etc/hosts; fi && \
    cd /tmp && curl -LO https://downloads.cloudera.com/connectors/impala_jdbc_2.6.4.1005.zip && \
    unzip impala_jdbc_2.6.4.1005.zip && rm impala_jdbc_2.6.4.1005.zip && cd ClouderaImpalaJDBC-2.6.4.1005 && \
    unzip ClouderaImpalaJDBC41-2.6.4.1005.zip && \
    source /etc/profile && mvn install:install-file -Dfile=/tmp/ClouderaImpalaJDBC-2.6.4.1005/ImpalaJDBC41.jar -DgroupId=Impala -DartifactId=ImpalaJDBC41 -Dversion=2.6.4 -Dpackaging=jar && \
    rm -rf /tmp/ClouderaImpalaJDBC-2.6.4.1005

## compile datalink
RUN source /etc/profile && cd /tmp && git clone ${datalink_git} -b ${branch} && cd DataLink && \
    mvn clean package -DskipTests && mkdir -p ${datalink_modules_home} && \
    mkdir -p ${datalink_manager_home} && mv ./target/dl-manager/* ${datalink_manager_home} && \
    mkdir -p ${datalink_worker_home} && mv ./target/dl-worker/* ${datalink_worker_home} && \
    rm -rf /tmp/DataLink && rm -rf ${java_repo_home}

# copy scripts & config
RUN mkdir -p ${datalink_manager_scripts_home} && mkdir -p ${datalink_worker_scripts_home}
COPY ./scripts/init-datalink-manager.sh ${datalink_manager_scripts_home}
COPY ./scripts/init-datalink-worker.sh ${datalink_worker_scripts_home}

COPY ./conf/datasource_template.properties ${datalink_manager_home}/conf/
COPY ./conf/datasource_template.properties ${datalink_worker_home}/conf/
COPY ./conf/manager_template.properties ${datalink_manager_home}/conf/
COPY ./conf/worker_template.properties ${datalink_worker_home}/conf/

RUN sed -i "s#{datalink_manager_home}#${datalink_manager_home}#g" ${datalink_manager_scripts_home}/init-datalink-manager.sh && \
    sed -i "s#{datalink_worker_home}#${datalink_worker_home}#g" ${datalink_worker_scripts_home}/init-datalink-worker.sh

COPY ./scripts/datalink-manager-start.sh /usr/local/bin/datalinkmanagerstart
COPY ./scripts/datalink-manager-stop.sh /usr/local/bin/datalinkmanagerstop
COPY ./scripts/datalink-manager-restart.sh /usr/local/bin/datalinkmanagerrestart
COPY ./scripts/datalink-worker-start.sh /usr/local/bin/datalinkworkerstart
COPY ./scripts/datalink-worker-stop.sh /usr/local/bin/datalinkworkerstop
COPY ./scripts/datalink-worker-restart.sh /usr/local/bin/datalinkworkerrestart
COPY ./scripts/datalink-not-start.sh /usr/local/bin/datalinknotstart
RUN sed -i "s#{datalink_manager_home}#${datalink_manager_home}#g" /usr/local/bin/datalinkmanagerstart && \
    sed -i "s#{datalink_manager_home}#${datalink_manager_home}#g" /usr/local/bin/datalinkmanagerstop && \
    chmod +x /usr/local/bin/datalinkmanagerstart && chmod +x /usr/local/bin/datalinkmanagerstop && chmod +x /usr/local/bin/datalinkmanagerrestart && \
    sed -i "s#{datalink_worker_home}#${datalink_worker_home}#g" /usr/local/bin/datalinkworkerstart && \
    sed -i "s#{datalink_worker_home}#${datalink_worker_home}#g" /usr/local/bin/datalinkworkerstop && \
    chmod +x /usr/local/bin/datalinkworkerstart && chmod +x /usr/local/bin/datalinkworkerstop && chmod +x /usr/local/bin/datalinkworkerrestart && \
    chmod +x /usr/local/bin/datalinknotstart

# init 
RUN echo "sh ${datalink_manager_scripts_home}/init-datalink-manager.sh && sh ${datalink_worker_scripts_home}/init-datalink-worker.sh && \${DATALINK_START}" >> /init_service