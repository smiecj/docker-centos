ARG IMAGE_TRINO_BASE
FROM ${IMAGE_TRINO_BASE}

# env
ENV PORT=7070
ENV HADOOP_CONF_DIR=/etc/hadoop/conf
ENV DATA_DIR=/home/data/trino
ENV HIVE_METASTORE_URL=localhost:8093
ENV XMX=4G

# arg
ARG module_home
ARG github_url
ARG trino_version

# script
COPY ./etc /tmp/etc
COPY ./scripts/init-trino.sh /tmp
COPY ./scripts/trino-start.sh /usr/local/bin/trinostart
COPY ./scripts/trino-stop.sh /usr/local/bin/trinostop
COPY ./scripts/trino-restart.sh /usr/local/bin/trinorestart

## compile
RUN trino_module_home=${module_home}/trino && \
    trino_script_home=${trino_module_home}/scripts && \
    yum -y install diffutils && \
    trino_repo=${github_url}/trinodb/trino && \
    mkdir -p ${trino_module_home} && cd ${trino_module_home} && git clone ${trino_repo} && \
    ## use jdk 17
    source /etc/profile && export JAVA_HOME=`echo ${JDK_HOME} | sed 's#.* ##g'` && export PATH=${JAVA_HOME}/bin:$PATH && \
    cd trino && git checkout tags/${trino_version} && \
    ## skip docs build (depend on docker)
    sed -i "s#.*>docs<.*##g" pom.xml && \
    mvn clean install -DskipTests && \
    trino_server_pkg=`ls -l trino-server/target/ | grep "SNAPSHOT.tar.gz" | sed 's#.* ##g'` && \
    trino_server_folder=`echo ${trino_server_pkg} | sed 's#.tar.*##g'` && \
    trino_client_jar=`ls -l trino-cli/target/ | grep "executable.jar" | sed 's#.* ##g'` && \
    mv trino-server/target/${trino_server_pkg} ${trino_module_home}/ && \
    mv trino-cli/target/${trino_client_jar} ${trino_module_home}/ && \
    cd .. && rm -rf trino && tar -xzvf ${trino_server_pkg} && rm ${trino_server_pkg} && \
    mv ${trino_server_folder}/* ./ && rm -rf ${trino_server_folder} && \
    mv ${trino_client_jar} bin/trino && \
    rm -r ~/.m2/repository/* && \

## copy config
    mkdir -p ${trino_module_home}/etc && mkdir -p ${trino_script_home} && \
    mv /tmp/etc/* ${trino_module_home}/etc/ && rm -r /tmp/etc && \
    mv /tmp/init-trino.sh ${trino_script_home}/ && \

## start and stop script
    sed -i "s#{trino_module_home}#${trino_module_home}#g" /usr/local/bin/trinostart && \
    sed -i "s#{trino_module_home}#${trino_module_home}#g" /usr/local/bin/trinostop && \
    sed -i "s#{trino_module_home}#${trino_module_home}#g" ${trino_script_home}/init-trino.sh && \
    chmod +x /usr/local/bin/trinostart && chmod +x /usr/local/bin/trinostop && chmod +x /usr/local/bin/trinorestart && \

## init service
    echo "sh ${trino_script_home}/init-trino.sh && trinostart" >> /init_service
