# download pkg to install prometheus, alertmanager
ARG MINIMAL_IMAGE
FROM ${MINIMAL_IMAGE}

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
ARG TARGETARCH
RUN mkdir -p ${prometheus_module_home} && mkdir -p ${prometheus_scripts_home} && \
    if [ "arm64" == "$TARGETARCH" ]; \
    then\
        arch="armv7";\
    else\
        arch="amd64";\
    fi && \
    prometheus_download_url=https://github.com/prometheus/prometheus/releases/download/v${prometheus_version}/prometheus-${prometheus_version}.linux-${arch}.tar.gz && \
    prometheus_pkg=`echo $prometheus_download_url | sed 's/.*\///g'` && \
    prometheus_folder=`echo $prometheus_pkg | sed 's/.tar.*//g'` && \
    cd /tmp && curl -LO $prometheus_download_url && \
    tar -xzvf ${prometheus_pkg} && mv ${prometheus_folder}/* ${prometheus_module_home}/ && \
    rm -rf ${prometheus_folder} && rm ${prometheus_pkg}

# install alertmanager
ARG alertmanager_version=0.23.0
ARG alertmanager_module_home=/home/modules/alertmanager
ARG alertmanager_scripts_home=${alertmanager_module_home}/scripts
ARG alertmanager_log=${prometheus_module_home}/alertmanager.log

ENV ALERTMANAGER_PORT=2113

## install pkg
RUN mkdir -p ${alertmanager_module_home} && mkdir -p ${alertmanager_scripts_home} && \
    if [ "arm64" == "$TARGETARCH" ]; \
    then\
        arch="armv7";\
    else\
        arch="amd64";\
    fi && \
    alertmanager_download_url=https://github.com/prometheus/alertmanager/releases/download/v${alertmanager_version}/alertmanager-${alertmanager_version}.linux-${arch}.tar.gz && \
    alertmanager_pkg=`echo $alertmanager_download_url | sed 's/.*\///g'` && \
    alertmanager_folder=`echo $alertmanager_pkg | sed 's/.tar.*//g'` && \
    cd /tmp && curl -LO $alertmanager_download_url && \
    tar -xzvf ${alertmanager_pkg} && mv ${alertmanager_folder}/* ${alertmanager_module_home}/ && \
    rm -rf ${alertmanager_folder} && rm ${alertmanager_pkg}

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