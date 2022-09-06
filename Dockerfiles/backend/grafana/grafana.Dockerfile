# download pkg to install prometheus, alertmanager and grafana
ARG MINIMAL_IMAGE
FROM ${MINIMAL_IMAGE}

USER root
ENV HOME /root

# install grafana
ARG grafana_version=8.4.2
ARG grafana_module_home=/opt/modules/grafana
ARG grafana_scripts_home=${grafana_module_home}/scripts
ARG grafana_log=${grafana_module_home}/grafana.log
ARG grafana_repo=https://mirrors.huaweicloud.com/grafana
# ARG grafana_repo=https://dl.grafana.com/enterprise/release

ENV PORT=3000

## install pkg
ARG TARGETARCH
RUN mkdir -p ${grafana_module_home} && mkdir -p ${grafana_scripts_home} && \
    if [ "arm64" == "$TARGETARCH" ]; \
    then\
        arch="arm64";\
    else\
        arch="amd64";\
    fi && \
    grafana_download_url=${grafana_repo}/${grafana_version}/grafana-enterprise-${grafana_version}.linux-${arch}.tar.gz && \
    grafana_pkg=`echo ${grafana_download_url} | sed 's/.*\///g'` && \
    grafana_folder="grafana-${grafana_version}" && \
    cd /tmp && curl -LO $grafana_download_url && \
    tar -xzvf ${grafana_pkg} && mv ${grafana_folder}/* ${grafana_module_home}/ && \
    rm -rf ${grafana_folder} && rm ${grafana_pkg}

# install grafana
RUN mkdir -p ${grafana_scripts_home}
COPY ./scripts/init-grafana.sh ${grafana_scripts_home}/
RUN sed -i "s#{grafana_module_home}#$grafana_module_home#g" ${grafana_scripts_home}/init-grafana.sh
COPY ./scripts/grafana-restart.sh /usr/local/bin/grafanarestart
COPY ./scripts/grafana-start.sh /usr/local/bin/grafanastart
COPY ./scripts/grafana-stop.sh /usr/local/bin/grafanastop
RUN chmod +x /usr/local/bin/grafanarestart && chmod +x /usr/local/bin/grafanastart && chmod +x /usr/local/bin/grafanastop
RUN sed -i "s#{grafana_module_home}#$grafana_module_home#g" /usr/local/bin/grafanastart && \
    sed -i "s#{grafana_log}#$grafana_log#g" /usr/local/bin/grafanastart && \
    sed -i "s#{grafana_module_home}#$grafana_module_home#g" /usr/local/bin/grafanastop
RUN echo "sh ${grafana_scripts_home}/init-grafana.sh && grafanastart" >> /init_service
RUN addlogrotate ${grafana_log} grafana
