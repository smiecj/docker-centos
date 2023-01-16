# download pkg to install prometheus, alertmanager and grafana
ARG IMAGE_MINIMAL
FROM ${IMAGE_MINIMAL}

USER root
ENV HOME /root

# install grafana
ARG module_home
ARG grafana_repo

# copy script
COPY ./scripts/init-grafana.sh /tmp/
COPY ./scripts/grafana-restart.sh /usr/local/bin/grafanarestart
COPY ./scripts/grafana-start.sh /usr/local/bin/grafanastart
COPY ./scripts/grafana-stop.sh /usr/local/bin/grafanastop

ARG grafana_version

ENV PORT=3000

## install pkg
ARG TARGETARCH
RUN grafana_module_home=${module_home}/grafana && \
    grafana_scripts_home=${grafana_module_home}/scripts && \
    grafana_log=${grafana_module_home}/grafana.log && \

    mkdir -p ${grafana_module_home} && mkdir -p ${grafana_scripts_home} && \
    if [ "arm64" == "$TARGETARCH" ]; \
    then\
        arch="arm64";\
    else\
        arch="amd64";\
    fi && \
    grafana_pkg=grafana-enterprise-${grafana_version}.linux-${arch}.tar.gz && \
    grafana_folder="grafana-${grafana_version}" && \
    if [[ ${grafana_repo} == *"dl.grafana.com"* ]]; \
    then\
        grafana_download_url=${grafana_repo}/${grafana_pkg};\
    else\
        grafana_download_url=${grafana_repo}/${grafana_version}/${grafana_pkg};\
    fi && \
    cd /tmp && curl -LO ${grafana_download_url} && \
    tar -xzvf ${grafana_pkg} && mv ${grafana_folder}/* ${grafana_module_home}/ && \
    rm -rf ${grafana_folder} && rm ${grafana_pkg} && \
    mkdir -p ${grafana_scripts_home} && \
    cp /tmp/init-grafana.sh ${grafana_scripts_home}/ && \

    sed -i "s#{grafana_module_home}#${grafana_module_home}#g" ${grafana_scripts_home}/init-grafana.sh && \
    chmod +x /usr/local/bin/grafanarestart && chmod +x /usr/local/bin/grafanastart && chmod +x /usr/local/bin/grafanastop && \
    sed -i "s#{grafana_module_home}#${grafana_module_home}#g" /usr/local/bin/grafanastart && \
    sed -i "s#{grafana_log}#${grafana_log}#g" /usr/local/bin/grafanastart && \ 
    sed -i "s#{grafana_module_home}#${grafana_module_home}#g" /usr/local/bin/grafanastop && \
    echo "sh ${grafana_scripts_home}/init-grafana.sh && grafanastart" >> /init_service && \
    addlogrotate ${grafana_log} grafana
