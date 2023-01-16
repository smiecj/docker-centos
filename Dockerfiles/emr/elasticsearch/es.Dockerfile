ARG IMAGE_MINIMAL
FROM ${IMAGE_MINIMAL}

ARG module_home
ARG TARGETARCH
ARG es_version

## env
ENV ES_PORT=9200

ENV XMX=1g
ENV XMS=1g

### scripts
COPY ./scripts/init-elasticsearch.sh /tmp
COPY ./conf/elasticsearch_template.yml /tmp
COPY ./conf/jvm_template.options /tmp

COPY ./scripts/elasticsearch-start.sh /usr/local/bin/elasticsearchstart
COPY ./scripts/elasticsearch-stop.sh /usr/local/bin/elasticsearchstop
COPY ./scripts/elasticsearch-restart.sh /usr/local/bin/elasticsearchrestart

## install elasticsearch
RUN ES_USER=elasticsearch && \
    es_module_home=${module_home}/elasticsearch && \
    es_scripts_home=${es_module_home}/scripts && \
    mkdir -p ${es_scripts_home} && \
    if [ "arm64" == "$TARGETARCH" ]; \
    then\
        arch="aarch64";\
    else\
        arch="x86_64";\
    fi && \
    es_download_url=https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${es_version}-linux-${arch}.tar.gz && \
    es_pkg=`echo ${es_download_url} | sed 's#.*/##g'` && \
    es_folder=elasticsearch-${es_version} && \
    mkdir -p ${es_module_home} && cd ${es_module_home} && \
    curl -LO ${es_download_url} && tar -xzvf ${es_pkg} && rm ${es_pkg} && \
    mv ${es_folder}/* ./ && rm -rf ${es_folder} && \

## add user
    useradd ${ES_USER} && \
    chown -R ${ES_USER}:${ES_USER} ${es_module_home} && \
    
## mv scripts
    mv /tmp/init-elasticsearch.sh ${es_scripts_home} && \
    mv /tmp/elasticsearch_template.yml ${es_module_home}/config/ && \
    mv /tmp/jvm_template.options ${es_module_home}/config/ && \
    sed -i "s#{es_module_home}#${es_module_home}#g" ${es_scripts_home}/init-elasticsearch.sh && \

    sed -i "s#{es_module_home}#${es_module_home}#g" /usr/local/bin/elasticsearchstart && \
    sed -i "s#{ES_USER}#${ES_USER}#g" /usr/local/bin/elasticsearchstart && \
    chmod +x /usr/local/bin/elasticsearchstart && chmod +x /usr/local/bin/elasticsearchstop && chmod +x /usr/local/bin/elasticsearchrestart && \

# init
    echo "sh ${es_scripts_home}/init-elasticsearch.sh && elasticsearchstart" >> /init_service