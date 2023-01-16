ARG IMAGE_JAVA
FROM ${IMAGE_JAVA}

ARG module_home
ARG hbase_version
ARG apache_repo

## env: hbase
ENV HBASE_MASTER_PORT=16000
ENV HBASE_MASTER_INFO_PORT=16010
ENV HBASE_REGION_SERVER_PORT=16201
ENV HBASE_REGION_SERVER_INFO_PORT=16301
ENV HBASE_THRIFT_PORT=9090

# copy scripts and config
COPY ./conf/hbase-site-template.xml /tmp
COPY ./scripts/init-hbase.sh /tmp
COPY ./scripts/hbase-start.sh /usr/local/bin/hbasestart
COPY ./scripts/hbase-stop.sh /usr/local/bin/hbasestop
COPY ./scripts/hbase-restart.sh /usr/local/bin/hbaserestart

## compile package
RUN hbase_module_home=${module_home}/hbase && \
    hbase_scripts_home=${hbase_module_home}/scripts && \
    yum -y install diffutils && \
    mkdir -p ${hbase_module_home} && cd ${hbase_module_home} && \
    hbase_long_version=`curl -L ${apache_repo}/hbase | grep ">${hbase_version}" | sed 's#.*">##g' | sed 's#<.*##g' | sed 's#/.*##g'` && \
    hbase_source_pkg=hbase-${hbase_long_version}-src.tar.gz && \
    hbase_source_folder=hbase-${hbase_long_version} && \
    hbase_pkg=hbase-${hbase_long_version}-bin.tar.gz && \
    hbase_folder=hbase-${hbase_long_version} && \
    hbase_source_url=${apache_repo}/hbase/${hbase_long_version}/${hbase_source_pkg} && \
    curl -LO ${hbase_source_url} && tar -xzvf ${hbase_source_pkg} && rm ${hbase_source_pkg} && \
    cd ${hbase_source_folder} && \
    source /etc/profile && mvn clean install -DskipTests assembly:single && \
    mv hbase-assembly/target/${hbase_pkg} ${hbase_module_home}/ && \
    rm -rf /tmp/${hbase_source_folder} && rm -rf ${java_repo_home} && \
    cd ${hbase_module_home} && tar -xzvf ${hbase_pkg} && rm ${hbase_pkg} && \
    mv ${hbase_folder}/* ./ && rm -rf ${hbase_folder} && \
    rm -rf ~/.m2/repository/* && \

# copy scripts & config
    mkdir -p ${hbase_scripts_home} && \
    mv /tmp/init-hbase.sh ${hbase_scripts_home} && \
    mv /tmp/hbase-site-template.xml ${hbase_module_home}/conf/ && \
    sed -i "s#{hbase_module_home}#${hbase_module_home}#g" ${hbase_scripts_home}/init-hbase.sh && \

    sed -i "s#{hbase_module_home}#${hbase_module_home}#g" /usr/local/bin/hbasestart && \
    sed -i "s#{hbase_module_home}#${hbase_module_home}#g" /usr/local/bin/hbasestop && \
    chmod +x /usr/local/bin/hbasestart && chmod +x /usr/local/bin/hbasestop && chmod +x /usr/local/bin/hbaserestart && \

# init 
    echo "sh ${hbase_scripts_home}/init-hbase.sh && hbasestart" >> /init_service