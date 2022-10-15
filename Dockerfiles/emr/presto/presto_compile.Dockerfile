ARG PRESTO_BASE_IMAGE
FROM ${PRESTO_BASE_IMAGE}

ARG repo_home=/home/repo
ARG java_repo_home=${repo_home}/java

# env
ENV PORT=7070
ENV HADOOP_CONF_DIR=/etc/hadoop/conf
ENV DATA_DIR=/home/data/presto
ENV HIVE_METASTORE_URL=localhost:8093

# arg
ARG presto_module_home=/opt/modules/presto
ARG presto_script_home=${presto_module_home}/scripts
ARG git_branch=release-0.275
ARG git_repo=https://github.com
ARG presto_repo=${git_repo}/prestodb/presto

## compile
RUN yum -y install diffutils
RUN mkdir -p ${presto_module_home} && cd ${presto_module_home} && git clone ${presto_repo} -b ${git_branch} && \
    source /etc/profile && cd presto && mvn clean install -DskipTests && \
    presto_server_pkg=`ls -l presto-server/target/ | grep "SNAPSHOT.tar.gz" | sed 's#.* ##g'` && \
    presto_server_folder=`echo ${presto_server_pkg} | sed 's#.tar.*##g'` && \
    presto_client_jar=`ls -l presto-cli/target/ | grep "executable.jar" | sed 's#.* ##g'` && \
    mv presto-server/target/${presto_server_pkg} ${presto_module_home}/ && \
    mv presto-cli/target/${presto_client_jar} ${presto_module_home}/ && \
    cd .. && rm -rf presto && tar -xzvf ${presto_server_pkg} && rm ${presto_server_pkg} && \
    mv ${presto_server_folder}/* ./ && rm -rf ${presto_server_folder} && \
    mv ${presto_client_jar} bin/presto && \
    rm -rf ${java_repo_home}

## copy config
RUN mkdir -p ${presto_module_home}/etc && mkdir -p ${presto_script_home}
COPY ./etc/ ${presto_module_home}/etc/
COPY ./scripts/init-presto.sh ${presto_script_home}/

## start and stop script
COPY ./scripts/presto-start.sh /usr/local/bin/prestostart
COPY ./scripts/presto-stop.sh /usr/local/bin/prestostop
COPY ./scripts/presto-restart.sh /usr/local/bin/prestorestart
RUN sed -i "s#{presto_module_home}#${presto_module_home}#g" /usr/local/bin/prestostart && \
    sed -i "s#{presto_module_home}#${presto_module_home}#g" /usr/local/bin/prestostop && \
    sed -i "s#{presto_module_home}#${presto_module_home}#g" ${presto_script_home}/init-presto.sh && \
    chmod +x /usr/local/bin/prestostart && chmod +x /usr/local/bin/prestostop && chmod +x /usr/local/bin/prestorestart

## init service
RUN echo "sh ${presto_script_home}/init-presto.sh && prestostart" >> /init_service
