ARG MINIMAL_IMAGE
FROM ${MINIMAL_IMAGE}

ARG modules_home=/opt/modules
ARG kibana_module_home=${modules_home}/kibana
ARG kibana_scripts_home=${kibana_module_home}/scripts

ARG TARGETARCH
ARG kibana_version=8.4.1

## env
ENV KIBANA_PORT=5601

ENV ES_ADDRESS=http://localhost:9200

## install kibana
RUN if [ "arm64" == "$TARGETARCH" ]; \
    then\
        arch="arm64";\
    else\
        arch="x86_64";\
    fi && \
    kibana_download_url=https://artifacts.elastic.co/downloads/kibana/kibana-${kibana_version}-linux-${arch}.tar.gz && \
    kibana_pkg=`echo ${kibana_download_url} | sed 's#.*/##g'` && \
    kibana_folder=kibana-${kibana_version} && \
    mkdir -p ${kibana_module_home} && cd ${kibana_module_home} && \
    curl -LO ${kibana_download_url} && tar -xzvf ${kibana_pkg} && rm ${kibana_pkg} && \
    mv ${kibana_folder}/* ./ && rm -rf ${kibana_folder}

# copy scripts
### kibana
RUN mkdir -p ${kibana_scripts_home}
COPY ./scripts/init-kibana.sh ${kibana_scripts_home}
COPY ./conf/kibana_template.yml ${kibana_module_home}/config/
RUN sed -i "s#{kibana_module_home}#${kibana_module_home}#g" ${kibana_scripts_home}/init-kibana.sh

COPY ./scripts/kibana-start.sh /usr/local/bin/kibanastart
COPY ./scripts/kibana-stop.sh /usr/local/bin/kibanastop
COPY ./scripts/kibana-restart.sh /usr/local/bin/kibanarestart

RUN sed -i "s#{kibana_module_home}#${kibana_module_home}#g" /usr/local/bin/kibanastart && \
    sed -i "s#{kibana_module_home}#${kibana_module_home}#g" /usr/local/bin/kibanastop && \
    chmod +x /usr/local/bin/kibanastart && chmod +x /usr/local/bin/kibanastop && chmod +x /usr/local/bin/kibanarestart

# init
RUN echo "sh ${kibana_scripts_home}/init-kibana.sh && kibanastart" >> /init_service
