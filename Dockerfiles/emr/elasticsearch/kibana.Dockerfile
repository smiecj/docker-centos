ARG IMAGE_MINIMAL
FROM ${IMAGE_MINIMAL}

ARG module_home
ARG TARGETARCH
ARG kibana_version

## env
ENV KIBANA_PORT=5601
ENV ES_ADDRESS=http://localhost:9200

### scripts
COPY ./scripts/init-kibana.sh /tmp
COPY ./conf/kibana_template.yml /tmp
COPY ./scripts/kibana-start.sh /usr/local/bin/kibanastart
COPY ./scripts/kibana-stop.sh /usr/local/bin/kibanastop
COPY ./scripts/kibana-restart.sh /usr/local/bin/kibanarestart

## install kibana
RUN kibana_module_home=${module_home}/kibana && \
    kibana_scripts_home=${kibana_module_home}/scripts && \
    mkdir -p ${kibana_scripts_home} && \
    if [ "arm64" == "$TARGETARCH" ]; \
    then\
        arch="aarch64";\
    else\
        arch="x86_64";\
    fi && \
    kibana_download_url=https://artifacts.elastic.co/downloads/kibana/kibana-${kibana_version}-linux-${arch}.tar.gz && \
    kibana_pkg=`echo ${kibana_download_url} | sed 's#.*/##g'` && \
    kibana_folder=kibana-${kibana_version} && \
    mkdir -p ${kibana_module_home} && cd ${kibana_module_home} && \
    curl -LO ${kibana_download_url} && tar -xzvf ${kibana_pkg} && rm ${kibana_pkg} && \
    mv ${kibana_folder}/* ./ && rm -rf ${kibana_folder} && \

# copy scripts
    mv /tmp/init-kibana.sh ${kibana_scripts_home} && \
    mv /tmp/kibana_template.yml ${kibana_module_home}/config/ && \
    sed -i "s#{kibana_module_home}#${kibana_module_home}#g" ${kibana_scripts_home}/init-kibana.sh && \
    sed -i "s#{kibana_module_home}#${kibana_module_home}#g" /usr/local/bin/kibanastart && \
    sed -i "s#{kibana_module_home}#${kibana_module_home}#g" /usr/local/bin/kibanastop && \
    chmod +x /usr/local/bin/kibanastart && chmod +x /usr/local/bin/kibanastop && chmod +x /usr/local/bin/kibanarestart && \

# init
    echo "sh ${kibana_scripts_home}/init-kibana.sh && kibanastart" >> /init_service