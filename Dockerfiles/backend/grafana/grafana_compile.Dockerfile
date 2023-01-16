ARG IMAGE_GO_NODEJS
FROM ${IMAGE_GO_NODEJS}

## prepare for component compile
ARG module_home
ARG grafana_version
ARG github_url
ARG TARGETARCH

ENV PORT=3000

COPY ./scripts/init-grafana.sh /tmp/
COPY ./scripts/grafana-restart.sh /usr/local/bin/grafanarestart
COPY ./scripts/grafana-start.sh /usr/local/bin/grafanastart
COPY ./scripts/grafana-stop.sh /usr/local/bin/grafanastop

# install grafana
RUN if [ "arm64" == "$TARGETARCH" ]; \
    then\
        arch="arm64";\
    else\
        arch="amd64";\
    fi && \

    code_home=/tmp && \
    source /etc/profile && npm -g install yarn typescript && \
    grafana_module_home=${module_home}/grafana && \
    grafana_bin_home=${grafana_module_home}/bin && \
    grafana_scripts_home=${grafana_module_home}/scripts && \
    grafana_log=${grafana_module_home}/grafana.log && \

## download source code
    grafana_source_pkg=v${grafana_version}.tar.gz && \
    grafana_source_url=${github_url}/grafana/grafana/archive/refs/tags/${grafana_source_pkg} && \
    grafana_code_home=${code_home}/grafana-${grafana_version} && \
    cd ${code_home} && curl -L ${grafana_source_url} -o ${grafana_source_pkg} && \
    tar -xzvf ${grafana_source_pkg} && rm ${grafana_source_pkg} && \

## compile and copy bin
    source /etc/profile && cd ${grafana_code_home} && rm yarn.lock && yarn install && GOARCH=${arch} make build && \
    mkdir -p ${grafana_module_home} && mkdir -p ${grafana_bin_home} && \
    cp -r ./conf ${grafana_module_home} && \
    cp ${grafana_module_home}/conf/defaults.ini ${grafana_module_home}/conf/custom.ini && \
    cp ./bin/linux-${arch}/* ${grafana_bin_home} && \
    cp -r ./public ${grafana_module_home} && \
    rm -r ${grafana_code_home} && \
    mkdir -p ${grafana_scripts_home} && cp /tmp/init-grafana.sh ${grafana_scripts_home}/ && \
## scripts
    sed -i "s#{grafana_module_home}#${grafana_module_home}#g" ${grafana_scripts_home}/init-grafana.sh && \
    chmod +x /usr/local/bin/grafanarestart && chmod +x /usr/local/bin/grafanastart && chmod +x /usr/local/bin/grafanastop && \
    sed -i "s#{grafana_module_home}#${grafana_module_home}#g" /usr/local/bin/grafanastart && \
    sed -i "s#{grafana_log}#$grafana_log#g" /usr/local/bin/grafanastart && \
    sed -i "s#{grafana_module_home}#${grafana_module_home}#g" /usr/local/bin/grafanastop && \
    echo "sh ${grafana_scripts_home}/init-grafana.sh && grafanastart" >> /init_service
