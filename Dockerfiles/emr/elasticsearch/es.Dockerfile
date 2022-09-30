ARG MINIMAL_IMAGE
FROM ${MINIMAL_IMAGE}

ARG modules_home=/opt/modules
ARG es_module_home=${modules_home}/elasticsearch
ARG es_scripts_home=${es_module_home}/scripts

ARG TARGETARCH
ARG es_version=8.4.1

## env
ENV ES_PORT=9200

ENV XMX=1g
ENV XMS=1g

## install elasticsearch
RUN if [ "arm64" == "$TARGETARCH" ]; \
    then\
        arch="arm64";\
    else\
        arch="x86_64";\
    fi && \
    es_download_url=https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${es_version}-linux-${arch}.tar.gz && \
    es_pkg=`echo ${es_download_url} | sed 's#.*/##g'` && \
    es_folder=elasticsearch-${es_version} && \
    mkdir -p ${es_module_home} && cd ${es_module_home} && \
    curl -LO ${es_download_url} && tar -xzvf ${es_pkg} && rm ${es_pkg} && \
    mv ${es_folder}/* ./ && rm -rf ${es_folder}

## add user
ARG ES_USER=elasticsearch
RUN useradd ${ES_USER}
RUN chown -R ${ES_USER}:${ES_USER} ${es_module_home}

# copy scripts
### elasticsearch
RUN mkdir -p ${es_scripts_home}
COPY ./scripts/init-elasticsearch.sh ${es_scripts_home}
COPY ./conf/elasticsearch_template.yml ${es_module_home}/config/
COPY ./conf/jvm_template.options ${es_module_home}/config/
RUN sed -i "s#{es_module_home}#${es_module_home}#g" ${es_scripts_home}/init-elasticsearch.sh

COPY ./scripts/elasticsearch-start.sh /usr/local/bin/elasticsearchstart
COPY ./scripts/elasticsearch-stop.sh /usr/local/bin/elasticsearchstop
COPY ./scripts/elasticsearch-restart.sh /usr/local/bin/elasticsearchrestart

RUN sed -i "s#{es_module_home}#${es_module_home}#g" /usr/local/bin/elasticsearchstart && \
    sed -i "s#{ES_USER}#${ES_USER}#g" /usr/local/bin/elasticsearchstart && \
    chmod +x /usr/local/bin/elasticsearchstart && chmod +x /usr/local/bin/elasticsearchstop && chmod +x /usr/local/bin/elasticsearchrestart

# init
RUN echo "sh ${es_scripts_home}/init-elasticsearch.sh && elasticsearchstart" >> /init_service
