# compile to install prometheus, alertmanager and grafana
ARG repo_home=/home/repo
ARG npm_repo_home=${repo_home}/nodejs

ARG NODEJS_IMAGE
ARG GO_IMAGE

FROM ${NODEJS_IMAGE} AS base_nodejs

USER root
ENV HOME /root

## prepare for component compile
ARG code_home=/tmp
RUN mkdir -p ${code_home}
RUN source /etc/profile && npm -g install yarn typescript

# install grafana
ARG grafana_version=8.4.2
ARG grafana_code_home=${code_home}/grafana-${grafana_version}
ARG grafana_module_home=/home/modules/grafana
ARG grafana_bin_home=${grafana_module_home}/bin
ARG grafana_scripts_home=${grafana_module_home}/scripts
ARG grafana_log=${grafana_module_home}/grafana.log

ENV PORT=3000

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
