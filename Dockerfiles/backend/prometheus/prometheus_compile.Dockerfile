# compile to install prometheus, alertmanager
ARG IMAGE_GO_NODEJS
FROM ${IMAGE_GO_NODEJS}

## prepare for component compile
ARG github_repo
ARG module_home

# install prometheus
ARG prometheus_version
ARG alertmanager_version
ARG pushgateway_version
ARG node_exporter_version

# copy scripts
COPY ./config/prometheus_template.yml /tmp
COPY ./scripts/init-prometheus.sh /tmp
COPY ./scripts/init-alertmanager.sh /tmp

COPY ./scripts/prometheus-restart.sh /usr/local/bin/prometheusrestart
COPY ./scripts/prometheus-start.sh /usr/local/bin/prometheusstart
COPY ./scripts/prometheus-stop.sh /usr/local/bin/prometheusstop

COPY ./scripts/alertmanager-restart.sh /usr/local/bin/alertmanagerrestart
COPY ./scripts/alertmanager-start.sh /usr/local/bin/alertmanagerstart
COPY ./scripts/alertmanager-stop.sh /usr/local/bin/alertmanagerstop

COPY ./scripts/pushgateway-restart.sh /usr/local/bin/pushgatewayrestart
COPY ./scripts/pushgateway-start.sh /usr/local/bin/pushgatewaystart
COPY ./scripts/pushgateway-stop.sh /usr/local/bin/pushgatewaystop

COPY ./scripts/nodeexporter-restart.sh /usr/local/bin/nodeexporterrestart
COPY ./scripts/nodeexporter-start.sh /usr/local/bin/nodeexporterstart
COPY ./scripts/nodeexporter-stop.sh /usr/local/bin/nodeexporterstop

ENV PROMETHEUS_PORT=3001
ENV ALERTMANAGER_PORT=2113
ENV NODE_EXPORTER_HOST=localhost
ENV NODE_EXPORTER_PORT=9100
ENV PUSHGATEWAY_HOST=localhost
ENV PUSHGATEWAY_PORT=9010

## download source code
RUN code_home=/tmp && \
    mkdir -p ${code_home} && \
    source /etc/profile && npm -g install yarn typescript && \
    ## fix node>=v17: digital envelope routines::unsupported
    ## https://github.com/prometheus/promlens/blob/main/README.md#building-from-source
    export NODE_OPTIONS=--openssl-legacy-provider && \
    prometheus_code_home=${code_home}/prometheus-${prometheus_version} && \
    prometheus_module_home=${module_home}/prometheus && \
    prometheus_scripts_home=${prometheus_module_home}/scripts && \
    prometheus_log=${prometheus_module_home}/prometheus.log && \
    prometheus_source_pkg=v${prometheus_version}.tar.gz && \
    prometheus_source_url=${github_repo}/prometheus/prometheus/archive/refs/tags/${prometheus_source_pkg} && \
    promu_release=${github_repo}/prometheus/promu/releases && \

    cd ${code_home} && curl -LO ${prometheus_source_url} && \
    tar -xzvf ${prometheus_source_pkg} && rm ${prometheus_source_pkg} && \

## compile and copy bin
    mkdir -p ${prometheus_module_home} && \
    mkdir -p ${prometheus_scripts_home} && \
    cd ${prometheus_code_home} && \
    sed -i "s#https.*/promu/releases#${promu_release}#g" Makefile.common && \
    make build && \
    cp ./documentation/examples/prometheus.yml ${prometheus_module_home} && \
    cp -r ./console_libraries ${prometheus_module_home} && \
    cp -r ./consoles ${prometheus_module_home} && \
    cp ./prometheus ${prometheus_module_home} && \
    cp ./promtool ${prometheus_module_home} && \
    cp ./LICENSE ${prometheus_module_home} && \
    cp ./NOTICE ${prometheus_module_home} && \
    mv /tmp/prometheus_template.yml ${prometheus_module_home}/ && \
    mv /tmp/init-prometheus.sh ${prometheus_scripts_home}/ && \
    rm -r ${prometheus_code_home} && \

# install alertmanager
    alertmanager_code_home=${code_home}/alertmanager-${alertmanager_version} && \
    alertmanager_module_home=${module_home}/alertmanager && \
    alertmanager_scripts_home=${alertmanager_module_home}/scripts && \
    alertmanager_log=${prometheus_module_home}/alertmanager.log && \

## download source code
    alertmanager_source_pkg=v${alertmanager_version}.tar.gz && \
    alertmanager_source_url=${github_repo}/prometheus/alertmanager/archive/refs/tags/${alertmanager_source_pkg} && \

    cd ${code_home} && curl -LO ${alertmanager_source_url} && \
    tar -xzvf ${alertmanager_source_pkg} && rm ${alertmanager_source_pkg} && \

## compile and copy bin
    mkdir -p ${alertmanager_module_home} && \
    mkdir -p ${alertmanager_scripts_home} && \
    cd ${alertmanager_code_home} && \
    sed -i "s#https.*/promu/releases#${promu_release}#g" Makefile.common && \
    make build && \
    cp ./alertmanager ${alertmanager_module_home} && \
    cp ./examples/ha/alertmanager.yml ${alertmanager_module_home} && \
    cp ./amtool ${alertmanager_module_home} && \
    cp ./LICENSE ${alertmanager_module_home} && \
    cp ./NOTICE ${alertmanager_module_home} && \
    mv /tmp/init-alertmanager.sh ${alertmanager_scripts_home}/ && \
    rm -r ${alertmanager_code_home} && \

# compile pushgateway
    pushgateway_home=${module_home}/pushgateway && \
    pushgateway_scripts_home=${pushgateway_home}/scripts && \

    mkdir -p ${pushgateway_home} && \
    mkdir -p ${pushgateway_scripts_home} && \
    pushgateway_source_pkg=v${pushgateway_version}.tar.gz && \
    pushgateway_source_url=${github_repo}/prometheus/pushgateway/archive/refs/tags/${pushgateway_source_pkg} && \
    pushgateway_code_home=${code_home}/pushgateway-${pushgateway_version} && \
    cd ${code_home} && curl -LO ${pushgateway_source_url} && \
    tar -xzvf ${pushgateway_source_pkg} && rm ${pushgateway_source_pkg} && \
    cd ${pushgateway_code_home} && \
    sed -i "s#https.*/promu/releases#${promu_release}#g" Makefile.common && \
    make build && \
    cp ./pushgateway-${pushgateway_version} ${pushgateway_home}/pushgateway && \
    cp ./LICENSE ${pushgateway_home} && \
    cp ./NOTICE ${pushgateway_home} && \
    rm -r ${pushgateway_code_home} && \

# compile node exporter
## suggest dashboard: https://grafana.com/grafana/dashboards/11074-node-exporter-for-prometheus-dashboard-en-v20201010/
    exporter_home=${module_home}/exporter && \

    node_exporter_home=${exporter_home}/nodeexporter && \
    node_exporter_scripts_home=${node_exporter_home}/scripts && \

    mkdir -p ${node_exporter_home} && \
    mkdir -p ${node_exporter_scripts_home} && \
    node_exporter_source_pkg=v${node_exporter_version}.tar.gz && \
    node_exporter_source_url=${github_repo}/prometheus/node_exporter/archive/refs/tags/${node_exporter_source_pkg} && \
    node_exporter_code_home=${code_home}/node_exporter-${node_exporter_version} && \
    cd ${code_home} && curl -LO ${node_exporter_source_url} && \
    tar -xzvf ${node_exporter_source_pkg} && rm ${node_exporter_source_pkg} && \
    cd ${node_exporter_code_home} && \
    sed -i "s#https.*/promu/releases#${promu_release}#g" Makefile.common && \
    make build && \
    cp ./node_exporter ${node_exporter_home} && \
    cp ./LICENSE ${node_exporter_home} && \
    cp ./NOTICE ${node_exporter_home} && \
    rm -r ${node_exporter_code_home} && \
    cd ${code_home} && \

# init script
## prometheus init script
    sed -i "s#{prometheus_module_home}#${prometheus_module_home}#g" ${prometheus_scripts_home}/init-prometheus.sh && \

    chmod +x /usr/local/bin/prometheusrestart && chmod +x /usr/local/bin/prometheusstart && chmod +x /usr/local/bin/prometheusstop && \
    sed -i "s#{prometheus_module_home}#$prometheus_module_home#g" /usr/local/bin/prometheusstart && \
    sed -i "s#{prometheus_log}#$prometheus_log#g" /usr/local/bin/prometheusstart && \
    sed -i "s#{prometheus_module_home}#$prometheus_module_home#g" /usr/local/bin/prometheusstop && \
    echo "sh ${prometheus_scripts_home}/init-prometheus.sh && prometheusstart" >> /init_service && \
    addlogrotate ${prometheus_log} prometheus && \

## alertmanager init script
    sed -i "s#{alertmanager_module_home}#$alertmanager_module_home#g" ${alertmanager_scripts_home}/init-alertmanager.sh && \

    chmod +x /usr/local/bin/alertmanagerrestart && chmod +x /usr/local/bin/alertmanagerstart && chmod +x /usr/local/bin/alertmanagerstop && \
    sed -i "s#{alertmanager_module_home}#$alertmanager_module_home#g" /usr/local/bin/alertmanagerstart && \
    sed -i "s#{alertmanager_log}#$alertmanager_log#g" /usr/local/bin/alertmanagerstart && \
    sed -i "s#{alertmanager_module_home}#$alertmanager_module_home#g" /usr/local/bin/alertmanagerstop && \
    echo "sh ${alertmanager_scripts_home}/init-alertmanager.sh && alertmanagerstart" >> /init_service && \
    addlogrotate ${alertmanager_log} alertmanager && \

## pushgateway
    chmod +x /usr/local/bin/pushgatewayrestart && chmod +x /usr/local/bin/pushgatewaystart && chmod +x /usr/local/bin/pushgatewaystop && \
    sed -i "s#{pushgateway_home}#$pushgateway_home#g" /usr/local/bin/pushgatewaystop && \
    sed -i "s#{pushgateway_home}#$pushgateway_home#g" /usr/local/bin/pushgatewaystart && \
    echo "pushgatewaystart" >> /init_service && \

## exporters
    chmod +x /usr/local/bin/nodeexporterrestart && chmod +x /usr/local/bin/nodeexporterstart && chmod +x /usr/local/bin/nodeexporterstop && \
    sed -i "s#{node_exporter_home}#$node_exporter_home#g" /usr/local/bin/nodeexporterstop && \
    sed -i "s#{node_exporter_home}#$node_exporter_home#g" /usr/local/bin/nodeexporterstart && \
    echo "nodeexporterstart" >> /init_service && \

## clean gopath and npm cache
    rm -r ${GOPATH}/* && \
    npm_cache_dir=`npm config get cache` && \
    npm_global_modules_dir=`npm config get prefix` && \
    rm -r ${npm_cache_dir} && rm -r ${npm_global_modules_dir}