# download pkg to install prometheus, alertmanager
ARG IMAGE_MINIMAL
FROM ${IMAGE_MINIMAL}

ARG module_home
ARG github_repo

ARG TARGETARCH
ARG prometheus_version
ARG alertmanager_version
ARG pushgateway_version
ARG node_exporter_version

ENV PROMETHEUS_HOST=localhost
ENV PROMETHEUS_PORT=3001

ENV ALERTMANAGER_HOST=localhost
ENV ALERTMANAGER_PORT=2113

ENV PUSHGATEWAY_HOST=localhost
ENV PUSHGATEWAY_PORT=9010

ENV NODE_EXPORTER_HOST=localhost
ENV NODE_EXPORTER_PORT=9100

# copy scripts
COPY ./scripts/init-prometheus.sh /tmp
COPY ./config/prometheus_template.yml /tmp
COPY ./scripts/prometheus-restart.sh /usr/local/bin/prometheusrestart
COPY ./scripts/prometheus-start.sh /usr/local/bin/prometheusstart
COPY ./scripts/prometheus-stop.sh /usr/local/bin/prometheusstop

COPY ./scripts/init-alertmanager.sh /tmp
COPY ./scripts/alertmanager-restart.sh /usr/local/bin/alertmanagerrestart
COPY ./scripts/alertmanager-start.sh /usr/local/bin/alertmanagerstart
COPY ./scripts/alertmanager-stop.sh /usr/local/bin/alertmanagerstop

COPY ./scripts/pushgateway-restart.sh /usr/local/bin/pushgatewayrestart
COPY ./scripts/pushgateway-start.sh /usr/local/bin/pushgatewaystart
COPY ./scripts/pushgateway-stop.sh /usr/local/bin/pushgatewaystop

COPY ./scripts/nodeexporter-restart.sh /usr/local/bin/nodeexporterrestart
COPY ./scripts/nodeexporter-start.sh /usr/local/bin/nodeexporterstart
COPY ./scripts/nodeexporter-stop.sh /usr/local/bin/nodeexporterstop

## install pkg

RUN prometheus_module_home=${module_home}/prometheus && \
    prometheus_scripts_home=${prometheus_module_home}/scripts && \
    prometheus_log=${prometheus_module_home}/prometheus.log && \
    mkdir -p ${prometheus_module_home} && mkdir -p ${prometheus_scripts_home} && \
    prometheus_download_url=${github_repo}/prometheus/prometheus/releases/download/v${prometheus_version}/prometheus-${prometheus_version}.linux-${TARGETARCH}.tar.gz && \
    prometheus_pkg=`echo $prometheus_download_url | sed 's/.*\///g'` && \
    prometheus_folder=`echo $prometheus_pkg | sed 's/.tar.*//g'` && \
    cd /tmp && curl -LO $prometheus_download_url && \
    tar -xzvf ${prometheus_pkg} && mv ${prometheus_folder}/* ${prometheus_module_home}/ && \
    rm -rf ${prometheus_folder} && rm ${prometheus_pkg} && \
    mkdir -p ${prometheus_scripts_home} && \
    mv /tmp/init-prometheus.sh ${prometheus_scripts_home}/ && \
    mv /tmp/prometheus_template.yml ${prometheus_module_home}/ && \

# install alertmanager
    alertmanager_module_home=${module_home}/alertmanager && \
    alertmanager_scripts_home=${alertmanager_module_home}/scripts && \
    alertmanager_log=${prometheus_module_home}/alertmanager.log && \

## install pkg
    mkdir -p ${alertmanager_module_home} && mkdir -p ${alertmanager_scripts_home} && \
    alertmanager_download_url=${github_repo}/prometheus/alertmanager/releases/download/v${alertmanager_version}/alertmanager-${alertmanager_version}.linux-${TARGETARCH}.tar.gz && \
    alertmanager_pkg=`echo $alertmanager_download_url | sed 's/.*\///g'` && \
    alertmanager_folder=`echo $alertmanager_pkg | sed 's/.tar.*//g'` && \
    cd /tmp && curl -LO $alertmanager_download_url && \
    tar -xzvf ${alertmanager_pkg} && mv ${alertmanager_folder}/* ${alertmanager_module_home}/ && \
    rm -rf ${alertmanager_folder} && rm ${alertmanager_pkg} && \
    mkdir -p ${alertmanager_scripts_home} && \
    mv /tmp/init-alertmanager.sh ${alertmanager_scripts_home}/ && \

# install pushgateway
    pushgateway_home=${module_home}/pushgateway && \

    mkdir -p ${pushgateway_home} && \
    pushgateway_download_url=${github_repo}/prometheus/pushgateway/releases/download/v${pushgateway_version}/pushgateway-${pushgateway_version}.linux-${TARGETARCH}.tar.gz && \
    pushgateway_pkg=`echo $pushgateway_download_url | sed 's/.*\///g'` && \
    pushgateway_folder=`echo $pushgateway_pkg | sed 's/.tar.*//g'` && \
    cd /tmp && curl -LO ${pushgateway_download_url} && \
    tar -xzvf ${pushgateway_pkg} && rm ${pushgateway_pkg} && \
    mv ${pushgateway_folder}/* ${pushgateway_home}/ && \
    rm -rf ${pushgateway_folder} && \

# install node exporter
## suggest dashboard: https://grafana.com/grafana/dashboards/11074-node-exporter-for-prometheus-dashboard-en-v20201010/
    exporter_home=${module_home}/exporter && \
    node_exporter_home=${exporter_home}/nodeexporter && \
    mkdir -p ${exporter_home} && mkdir -p ${node_exporter_home} && \
    node_exporter_download_url=${github_repo}/prometheus/node_exporter/releases/download/v${node_exporter_version}/node_exporter-${node_exporter_version}.linux-${TARGETARCH}.tar.gz && \
    node_exporter_pkg=`echo $node_exporter_download_url | sed 's/.*\///g'` && \
    node_exporter_folder=`echo $node_exporter_pkg | sed 's/.tar.*//g'` && \
    cd /tmp && curl -LO $node_exporter_download_url && \
    tar -xzvf ${node_exporter_pkg} && rm ${node_exporter_pkg} && \
    mv ${node_exporter_folder}/node_exporter ${node_exporter_home}/ && \
    rm -rf ${node_exporter_folder} && \

# init script
## prometheus init script
    sed -i "s#{prometheus_module_home}#$prometheus_module_home#g" ${prometheus_scripts_home}/init-prometheus.sh && \
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
    echo "nodeexporterstart" >> /init_service