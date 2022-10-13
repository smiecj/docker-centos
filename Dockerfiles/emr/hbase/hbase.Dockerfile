# azkaban single node
ARG JAVA_IMAGE
FROM ${JAVA_IMAGE}

ARG hbase_module_home=/opt/modules/hbase
ARG hbase_short_version=2.5
ARG hbase_scripts_home=${hbase_module_home}/scripts

ARG apache_repo=https://mirrors.tuna.tsinghua.edu.cn/apache
# ARG apache_repo=https://dlcdn.apache.org

## env: hbase
ENV HBASE_MASTER_PORT=16000
ENV HBASE_MASTER_INFO_PORT=16010
ENV HBASE_REGION_SERVER_PORT=16201
ENV HBASE_REGION_SERVER_INFO_PORT=16301
ENV HBASE_THRIFT_PORT=9090

## download package
RUN mkdir -p ${hbase_module_home} && cd ${hbase_module_home} && \
    hbase_long_version=`curl -L ${apache_repo}/hbase | grep ">${hbase_short_version}" | sed 's#.*">##g' | sed 's#<.*##g' | sed 's#/.*##g'` && \
    hbase_pkg=hbase-${hbase_long_version}-bin.tar.gz && \
    hbase_folder=hbase-${hbase_long_version} && \
    hbase_pkg_url=${apache_repo}/hbase/${hbase_long_version}/${hbase_pkg} && \
    curl -LO ${hbase_pkg_url} && tar -xzvf ${hbase_pkg} && rm ${hbase_pkg} && \
    mv ${hbase_folder}/* ./ && rm -rf ${hbase_folder}

# copy scripts & config
COPY ./conf/hbase-site-template.xml ${hbase_module_home}/conf/
RUN mkdir -p ${hbase_scripts_home}
COPY ./scripts/init-hbase.sh ${hbase_scripts_home}
RUN sed -i "s#{hbase_module_home}#${hbase_module_home}#g" ${hbase_scripts_home}/init-hbase.sh

COPY ./scripts/hbase-start.sh /usr/local/bin/hbasestart
COPY ./scripts/hbase-stop.sh /usr/local/bin/hbasestop
COPY ./scripts/hbase-restart.sh /usr/local/bin/hbaserestart
RUN sed -i "s#{hbase_module_home}#${hbase_module_home}#g" /usr/local/bin/hbasestart && \
    sed -i "s#{hbase_module_home}#${hbase_module_home}#g" /usr/local/bin/hbasestop && \
    chmod +x /usr/local/bin/hbasestart && chmod +x /usr/local/bin/hbasestop && chmod +x /usr/local/bin/hbaserestart

# init 
RUN echo "sh ${hbase_scripts_home}/init-hbase.sh && hbasestart" >> /init_service