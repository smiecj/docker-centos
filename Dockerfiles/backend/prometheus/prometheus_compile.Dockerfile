# compile to install prometheus, alertmanager
ARG repo_home=/home/repo
ARG npm_repo_home=${repo_home}/nodejs
ARG go_repo_home=$repo_home/go

ARG NODEJS_IMAGE
ARG GO_IMAGE

FROM ${NODEJS_IMAGE} AS base_nodejs

FROM ${GO_IMAGE} AS base_golang

USER root
ENV HOME /root

ARG module_home=/opt/modules

ARG github_repo=https://github.com
# ARG github_repo=https://download.fastgit.org
ARG promu_release=${github_repo}/prometheus/promu/releases

## copy npm package
ARG repo_home
ARG npm_repo_home
ARG npm_home=/usr/nodejs
RUN mkdir -p ${npm_home} && mkdir -p ${npm_repo_home}
COPY --from=base_nodejs ${npm_home}/ ${npm_home}/

## mkdir npm repo folder
RUN mkdir -p $npm_repo_home/global_modules && mkdir -p $npm_repo_home/cache

## npm profile
COPY --from=base_nodejs /etc/profile /tmp/profile_nodejs
RUN sed -n '/# nodejs/,$p' /tmp/profile_nodejs >> /etc/profile
RUN rm /tmp/profile_nodejs
COPY --from=base_nodejs $HOME/.npmrc $HOME/

## prepare for component compile
ARG code_home=/tmp
RUN mkdir -p ${code_home}
RUN source /etc/profile && npm -g install yarn typescript

# install prometheus
ARG prometheus_version=2.33.4
ARG prometheus_code_home=${code_home}/prometheus-${prometheus_version}
ARG prometheus_module_home=${module_home}/prometheus
ARG prometheus_scripts_home=${prometheus_module_home}/scripts
ARG prometheus_log=${prometheus_module_home}/prometheus.log

ENV PROMETHEUS_PORT=3001

## download source code
ARG prometheus_source_url=${github_repo}/prometheus/prometheus/archive/refs/tags/v${prometheus_version}.tar.gz
ARG prometheus_source_pkg=prometheus_code.tar.gz
RUN cd ${code_home} && curl -L ${prometheus_source_url} -o ${prometheus_source_pkg} && \
    tar -xzvf ${prometheus_source_pkg} && rm -f ${prometheus_source_pkg}

## compile and copy bin
RUN mkdir -p ${prometheus_module_home}
RUN cd ${prometheus_code_home} && source /etc/profile && \
    sed -i "s#https.*/promu/releases#${promu_release}#g" Makefile.common && \
    make build && \
    cp ./documentation/examples/prometheus.yml ${prometheus_module_home} && \
    cp -r ./console_libraries ${prometheus_module_home} && \
    cp -r ./consoles ${prometheus_module_home} && \
    cp ./prometheus ${prometheus_module_home} && \
    cp ./promtool ${prometheus_module_home} && \
    cp ./LICENSE ${prometheus_module_home} && \
    cp ./NOTICE ${prometheus_module_home} && \
    rm -rf ${prometheus_code_home}

## copy conf template
COPY ./config/prometheus_template.yml ${prometheus_module_home}/

# install alertmanager
ARG alertmanager_version=0.23.0
ARG alertmanager_code_home=${code_home}/alertmanager-${alertmanager_version}
ARG alertmanager_module_home=${module_home}/alertmanager
ARG alertmanager_scripts_home=${alertmanager_module_home}/scripts
ARG alertmanager_log=${prometheus_module_home}/alertmanager.log

ENV ALERTMANAGER_PORT=2113

## download source code
ARG alertmanager_source_url=${github_repo}/prometheus/alertmanager/archive/refs/tags/v${alertmanager_version}.tar.gz
ARG alertmanager_source_pkg=alertmanager_code.tar.gz
RUN cd ${code_home} && curl -L ${alertmanager_source_url} -o ${alertmanager_source_pkg} && \
    tar -xzvf ${alertmanager_source_pkg} && rm -f ${alertmanager_source_pkg}

## compile and copy bin
RUN mkdir -p ${alertmanager_module_home}
RUN cd ${alertmanager_code_home} && source /etc/profile && \
    sed -i "s#https.*/promu/releases#${promu_release}#g" Makefile.common && \
    make build && \
    cp ./alertmanager ${alertmanager_module_home} && \
    cp ./examples/ha/alertmanager.yml ${alertmanager_module_home} && \
    cp ./amtool ${alertmanager_module_home} && \
    cp ./LICENSE ${alertmanager_module_home} && \
    cp ./NOTICE ${alertmanager_module_home} && \
    rm -rf ${alertmanager_code_home}

# compile pushgateway
ARG pushgateway_home=${module_home}/pushgateway
ARG pushgateway_scripts_home=${pushgateway_home}/scripts
ARG pushgateway_version=1.4.3

ENV PUSHGATEWAY_HOST=localhost
ENV PUSHGATEWAY_PORT=9010

RUN mkdir -p ${pushgateway_home} && \
    pushgateway_source_url=${github_repo}/prometheus/pushgateway/archive/refs/tags/v${pushgateway_version}.tar.gz && \
    pushgateway_source_pkg=pushgateway_code.tar.gz && \
    pushgateway_code_home=${code_home}/pushgateway-${pushgateway_version} && \
    cd ${code_home} && curl -L ${pushgateway_source_url} -o ${pushgateway_source_pkg} && \
    tar -xzvf ${pushgateway_source_pkg} && rm -f ${pushgateway_source_pkg} && \
    cd ${pushgateway_code_home} && source /etc/profile && \
    sed -i "s#https.*/promu/releases#${promu_release}#g" Makefile.common && \
    make build && \
    cp ./pushgateway-${pushgateway_version} ${pushgateway_home}/pushgateway && \
    cp ./LICENSE ${pushgateway_home} && \
    cp ./NOTICE ${pushgateway_home} && \
    rm -rf ${pushgateway_code_home}

# compile node exporter
## suggest dashboard: https://grafana.com/grafana/dashboards/11074-node-exporter-for-prometheus-dashboard-en-v20201010/
ARG exporter_home=${module_home}/exporter

ARG node_exporter_version=1.3.1
ARG node_exporter_home=${exporter_home}/nodeexporter
ARG node_exporter_scripts_home=${node_exporter_home}/scripts

ENV NODE_EXPORTER_HOST=localhost
ENV NODE_EXPORTER_PORT=9100

RUN mkdir -p ${node_exporter_home} && \
    node_exporter_source_url=${github_repo}/prometheus/node_exporter/archive/refs/tags/v${node_exporter_version}.tar.gz && \
    node_exporter_source_pkg=node_exporter_code.tar.gz && \
    node_exporter_code_home=${code_home}/node_exporter-${node_exporter_version} && \
    cd ${code_home} && curl -L ${node_exporter_source_url} -o ${node_exporter_source_pkg} && \
    tar -xzvf ${node_exporter_source_pkg} && rm -f ${node_exporter_source_pkg} && \
    cd ${node_exporter_code_home} && source /etc/profile && \
    sed -i "s#https.*/promu/releases#${promu_release}#g" Makefile.common && \
    make build && \
    cp ./node_exporter ${node_exporter_home} && \
    cp ./LICENSE ${node_exporter_home} && \
    cp ./NOTICE ${node_exporter_home} && \
    rm -rf ${node_exporter_code_home}

# init script
## prometheus init script
RUN mkdir -p ${prometheus_scripts_home}
COPY ./scripts/init-prometheus.sh ${prometheus_scripts_home}/
RUN sed -i "s#{prometheus_module_home}#$prometheus_module_home#g" ${prometheus_scripts_home}/init-prometheus.sh
COPY ./scripts/prometheus-restart.sh /usr/local/bin/prometheusrestart
COPY ./scripts/prometheus-start.sh /usr/local/bin/prometheusstart
COPY ./scripts/prometheus-stop.sh /usr/local/bin/prometheusstop
RUN chmod +x /usr/local/bin/prometheusrestart && chmod +x /usr/local/bin/prometheusstart && chmod +x /usr/local/bin/prometheusstop
RUN sed -i "s#{prometheus_module_home}#$prometheus_module_home#g" /usr/local/bin/prometheusstart && \
    sed -i "s#{prometheus_log}#$prometheus_log#g" /usr/local/bin/prometheusstart && \
    sed -i "s#{prometheus_module_home}#$prometheus_module_home#g" /usr/local/bin/prometheusstop
RUN echo "sh ${prometheus_scripts_home}/init-prometheus.sh && prometheusstart" >> /init_service
RUN addlogrotate ${prometheus_log} prometheus

## alertmanager init script
RUN mkdir -p ${alertmanager_scripts_home}
COPY ./scripts/init-alertmanager.sh ${alertmanager_scripts_home}/
RUN sed -i "s#{alertmanager_module_home}#$alertmanager_module_home#g" ${alertmanager_scripts_home}/init-alertmanager.sh
COPY ./scripts/alertmanager-restart.sh /usr/local/bin/alertmanagerrestart
COPY ./scripts/alertmanager-start.sh /usr/local/bin/alertmanagerstart
COPY ./scripts/alertmanager-stop.sh /usr/local/bin/alertmanagerstop
RUN chmod +x /usr/local/bin/alertmanagerrestart && chmod +x /usr/local/bin/alertmanagerstart && chmod +x /usr/local/bin/alertmanagerstop
RUN sed -i "s#{alertmanager_module_home}#$alertmanager_module_home#g" /usr/local/bin/alertmanagerstart && \
    sed -i "s#{alertmanager_log}#$alertmanager_log#g" /usr/local/bin/alertmanagerstart && \
    sed -i "s#{alertmanager_module_home}#$alertmanager_module_home#g" /usr/local/bin/alertmanagerstop
RUN echo "sh ${alertmanager_scripts_home}/init-alertmanager.sh && alertmanagerstart" >> /init_service
RUN addlogrotate ${alertmanager_log} alertmanager

## pushgateway
RUN mkdir -p ${pushgateway_scripts_home}
COPY ./scripts/pushgateway-restart.sh /usr/local/bin/pushgatewayrestart
COPY ./scripts/pushgateway-start.sh /usr/local/bin/pushgatewaystart
COPY ./scripts/pushgateway-stop.sh /usr/local/bin/pushgatewaystop
RUN chmod +x /usr/local/bin/pushgatewayrestart && chmod +x /usr/local/bin/pushgatewaystart && chmod +x /usr/local/bin/pushgatewaystop && \
    sed -i "s#{pushgateway_home}#$pushgateway_home#g" /usr/local/bin/pushgatewaystop && \
    sed -i "s#{pushgateway_home}#$pushgateway_home#g" /usr/local/bin/pushgatewaystart && \
    echo "pushgatewaystart" >> /init_service

## exporters
RUN mkdir -p ${node_exporter_scripts_home}
COPY ./scripts/nodeexporter-restart.sh /usr/local/bin/nodeexporterrestart
COPY ./scripts/nodeexporter-start.sh /usr/local/bin/nodeexporterstart
COPY ./scripts/nodeexporter-stop.sh /usr/local/bin/nodeexporterstop
RUN chmod +x /usr/local/bin/nodeexporterrestart && chmod +x /usr/local/bin/nodeexporterstart && chmod +x /usr/local/bin/nodeexporterstop && \
    sed -i "s#{node_exporter_home}#$node_exporter_home#g" /usr/local/bin/nodeexporterstop && \
    sed -i "s#{node_exporter_home}#$node_exporter_home#g" /usr/local/bin/nodeexporterstart && \
    echo "nodeexporterstart" >> /init_service

## clean gopath
ARG go_repo_home
RUN rm -rf ${go_repo_home}/*