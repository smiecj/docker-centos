# download pkg to install prometheus, alertmanager and grafana
FROM centos_minimal

USER root
ENV HOME /root

# install npm
## 后续: 如果有重复代码，看是否可以把 npm 和 golang 打包到一个镜像中

# install prometheus
ARG prometheus_version=2.33.4
ARG prometheus_module_home=/home/modules/prometheus
ARG prometheus_scripts_home=${prometheus_module_home}/scripts
ARG prometheus_log=${prometheus_module_home}/prometheus.log

ENV PROMETHEUS_PORT=3001

## install pkg
RUN mkdir -p ${prometheus_module_home} && mkdir -p ${prometheus_scripts_home}
COPY ./env_prometheus.sh /tmp/
RUN . /tmp/env_prometheus.sh && cd /tmp && curl -LO $prometheus_download_url && \
    tar -xzvf ${prometheus_pkg} && mv ${prometheus_folder}/* ${prometheus_module_home}/ && \
    rm -rf ${prometheus_folder} && rm ${prometheus_pkg}
RUN rm /tmp/env_prometheus.sh

# install alertmanager
ARG alertmanager_version=0.23.0
ARG alertmanager_module_home=/home/modules/alertmanager
ARG alertmanager_scripts_home=${alertmanager_module_home}/scripts
ARG alertmanager_log=${prometheus_module_home}/alertmanager.log

ENV ALERTMANAGER_PORT=2113

## install pkg
RUN mkdir -p ${alertmanager_module_home} && mkdir -p ${alertmanager_scripts_home}
COPY ./env_alertmanager.sh /tmp/
RUN . /tmp/env_alertmanager.sh && cd /tmp && curl -LO $alertmanager_download_url && \
    tar -xzvf ${alertmanager_pkg} && mv ${alertmanager_folder}/* ${alertmanager_module_home}/ && \
    rm -rf ${alertmanager_folder} && rm ${alertmanager_pkg}
RUN rm /tmp/env_alertmanager.sh

# install grafana
ARG grafana_version=8.4.2
ARG grafana_module_home=/home/modules/grafana
ARG grafana_scripts_home=${grafana_module_home}/scripts
ARG grafana_log=${grafana_module_home}/grafana.log

ENV GRAFANA_PORT=3000

## install pkg
RUN mkdir -p ${grafana_module_home} && mkdir -p ${grafana_scripts_home}
COPY ./env_grafana.sh /tmp/
RUN . /tmp/env_grafana.sh && cd /tmp && curl -LO $grafana_download_url && \
    tar -xzvf ${grafana_pkg} && mv ${grafana_folder}/* ${grafana_module_home}/ && \
    rm -rf ${grafana_folder} && rm ${grafana_pkg}
RUN rm /tmp/env_grafana.sh

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
