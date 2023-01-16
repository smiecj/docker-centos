ARG IMAGE_PRESTO_BASE
FROM ${IMAGE_PRESTO_BASE}

# env
ENV PORT=7070
ENV HADOOP_CONF_DIR=/etc/hadoop/conf
ENV DATA_DIR=/home/data/presto
ENV HIVE_METASTORE_URL=localhost:8093
ENV XMX=4G

# arg
ARG module_home
ARG github_url
ARG presto_version

# script
COPY ./etc /tmp/etc
COPY ./scripts/init-presto.sh /tmp
COPY ./scripts/presto-start.sh /usr/local/bin/prestostart
COPY ./scripts/presto-stop.sh /usr/local/bin/prestostop
COPY ./scripts/presto-restart.sh /usr/local/bin/prestorestart

## compile
RUN presto_module_home=${module_home}/presto && \
    presto_script_home=${presto_module_home}/scripts && \
    presto_git_branch=release-${presto_version} && \
    yum -y install diffutils && \
    presto_repo=${github_url}/prestodb/presto && \
    mkdir -p ${presto_module_home} && cd ${presto_module_home} && git clone ${presto_repo} -b ${presto_git_branch} && \
    source /etc/profile && cd presto && mvn clean install -DskipTests && \
    presto_server_pkg=`ls -l presto-server/target/ | grep "SNAPSHOT.tar.gz" | sed 's#.* ##g'` && \
    presto_server_folder=`echo ${presto_server_pkg} | sed 's#.tar.*##g'` && \
    presto_client_jar=`ls -l presto-cli/target/ | grep "executable.jar" | sed 's#.* ##g'` && \
    mv presto-server/target/${presto_server_pkg} ${presto_module_home}/ && \
    mv presto-cli/target/${presto_client_jar} ${presto_module_home}/ && \
    cd .. && rm -rf presto && tar -xzvf ${presto_server_pkg} && rm ${presto_server_pkg} && \
    mv ${presto_server_folder}/* ./ && rm -rf ${presto_server_folder} && \
    mv ${presto_client_jar} bin/presto && \
    rm -r ~/.m2/repository/* && \

## copy config
    mkdir -p ${presto_module_home}/etc && mkdir -p ${presto_script_home} && \
    mv /tmp/etc/* ${presto_module_home}/etc/ && rm -r /tmp/etc && \
    mv /tmp/init-presto.sh ${presto_script_home}/ && \

## start and stop script
    sed -i "s#{presto_module_home}#${presto_module_home}#g" /usr/local/bin/prestostart && \
    sed -i "s#{presto_module_home}#${presto_module_home}#g" /usr/local/bin/prestostop && \
    sed -i "s#{presto_module_home}#${presto_module_home}#g" ${presto_script_home}/init-presto.sh && \
    chmod +x /usr/local/bin/prestostart && chmod +x /usr/local/bin/prestostop && chmod +x /usr/local/bin/prestorestart && \

## init service
    echo "sh ${presto_script_home}/init-presto.sh && prestostart" >> /init_service
