# compile to install prometheus, alertmanager and grafana
ARG repo_home=/home/repo
ARG npm_repo_home=${repo_home}/nodejs

FROM ${NODEJS_IMAGE} AS base_nodejs

FROM ${GO_IMAGE} AS base_golang

USER root
ENV HOME /root

# install npm
## 后续: 如果有重复代码，看是否可以把 npm 和 golang 打包到一个镜像中

## copy npm package
ARG repo_home
ARG npm_repo_home
ARG npm_home=/usr/nodejs
RUN mkdir -p {npm_home} && mkdir -p ${npm_repo_home}
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
ARG prometheus_module_home=/home/modules/prometheus
ARG prometheus_scripts_home=${prometheus_module_home}/scripts
ARG prometheus_log=${prometheus_module_home}/prometheus.log

ENV PROMETHEUS_PORT=3001

## download source code
ARG prometheus_source_url=https://github.com/prometheus/prometheus/archive/refs/tags/v${prometheus_version}.tar.gz
ARG prometheus_source_pkg=prometheus_code.tar.gz
RUN cd ${code_home} && curl -L ${prometheus_source_url} -o ${prometheus_source_pkg} && \
    tar -xzvf ${prometheus_source_pkg} && rm -f ${prometheus_source_pkg}

## compile and copy bin
RUN mkdir -p ${prometheus_module_home}
RUN cd ${prometheus_code_home} && sed -i "s/npm install/yarn install --loglevel verbose/g" Makefile && source /etc/profile && make build && \
    cp ./documentation/examples/prometheus.yml ${prometheus_module_home} && \
    cp -r ./console_libraries ${prometheus_module_home} && \
    cp -r ./consoles ${prometheus_module_home} && \
    cp ./prometheus ${prometheus_module_home} && \
    cp ./promtool ${prometheus_module_home} && \
    cp ./LICENSE ${prometheus_module_home} && \
    cp ./NOTICE ${prometheus_module_home} && \
    rm -rf ${prometheus_code_home}

# install alertmanager
ARG alertmanager_version=0.23.0
ARG alertmanager_code_home=${code_home}/alertmanager-${alertmanager_version}
ARG alertmanager_module_home=/home/modules/alertmanager
ARG alertmanager_scripts_home=${alertmanager_module_home}/scripts
ARG alertmanager_log=${prometheus_module_home}/alertmanager.log

ENV ALERTMANAGER_PORT=2113

## download source code
ARG alertmanager_source_url=https://github.com/prometheus/alertmanager/archive/refs/tags/v${alertmanager_version}.tar.gz
ARG alertmanager_source_pkg=alertmanager_code.tar.gz
RUN cd ${code_home} && curl -L ${alertmanager_source_url} -o ${alertmanager_source_pkg} && \
    tar -xzvf ${alertmanager_source_pkg} && rm -f ${alertmanager_source_pkg}

## compile and copy bin
RUN mkdir -p ${alertmanager_module_home}
RUN cd ${alertmanager_code_home} && source /etc/profile && make build && \
    cp ./alertmanager ${alertmanager_module_home} && \
    cp ./examples/ha/alertmanager.yml ${alertmanager_module_home} && \
    cp ./amtool ${alertmanager_module_home} && \
    cp ./LICENSE ${alertmanager_module_home} && \
    cp ./NOTICE ${alertmanager_module_home} && \
    rm -rf ${alertmanager_code_home}

# install grafana
ARG grafana_version=8.4.2
ARG grafana_code_home=${code_home}/grafana-${grafana_version}
ARG grafana_module_home=/home/modules/grafana
ARG grafana_bin_home=${grafana_module_home}/bin
ARG grafana_scripts_home=${grafana_module_home}/scripts
ARG grafana_log=${grafana_module_home}/grafana.log

ENV GRAFANA_PORT=3000

## download source code
ARG grafana_source_url=https://github.com/grafana/grafana/archive/refs/tags/v${grafana_version}.tar.gz
ARG grafana_source_pkg=grafana_code.tar.gz
RUN cd ${code_home} && curl -L ${grafana_source_url} -o ${grafana_source_pkg} && \
    tar -xzvf ${grafana_source_pkg} && rm -f ${grafana_source_pkg}

## compile and copy bin
RUN mkdir -p ${grafana_code_home} && mkdir -p ${grafana_bin_home}
RUN source /etc/profile && npm -g install yarn && cd ${grafana_code_home} && rm yarn.lock && yarn install
RUN cd ${grafana_code_home} && source /etc/profile && make build && \
    cp -r ./conf ${grafana_module_home} && \
    cp ${grafana_module_home}/conf/defaults.ini ${grafana_module_home}/conf/custom.ini && \
    cp ./bin/linux-amd64/* ${grafana_bin_home} && \
    cp -r ./public ${grafana_module_home} && \
    rm -rf ${grafana_code_home}

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
RUN addlogrotate ${redis_log_path} redis-server

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
