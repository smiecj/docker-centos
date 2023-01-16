ARG IMAGE_DEV_FULL
FROM ${IMAGE_DEV_FULL}

ARG TARGETARCH

ARG code_server_short_version=4.5.1
ARG code_server_version=v${code_server_short_version}
ARG module_home
ARG code_server_module_home=${module_home}/code_server
ARG code_server_log_home=/var/log/code-server
ARG code_server_log=${code_server_log_home}/code-server.log
ARG code_server_scripts_home={code_server_module_home}/scripts

ARG github_repo

ENV PORT=8080
ENV PASSWORD=test_code_server

# install code-server
ARG TARGETARCH
RUN code_server_download_url_prefix=${github_repo}/coder/code-server/releases/download && \
    mkdir -p ${module_home} && cd ${module_home} && \
    code_server_pkg=code-server-${code_server_short_version}-linux-${TARGETARCH}.tar.gz && \
    code_server_folder=code-server-${code_server_short_version}-linux-${TARGETARCH} && \
    code_server_download_url=${code_server_download_url_prefix}/${code_server_version}/${code_server_pkg} && \
    curl -LO ${code_server_download_url} && tar -xzvf ${code_server_pkg} && rm ${code_server_pkg} && \
    mv ${code_server_folder} code_server

# install code-server plugins
ARG EXTENSION_VERSION=v1
ARG extension_file=/tmp/${EXTENSION_VERSION}.txt
COPY ./extensions/${EXTENSION_VERSION}.txt ${extension_file}
RUN cat ${extension_file} | xargs -I {} bash -c 'if [[ ! "{}" =~ ^# ]]; then echo "{}"; fi' | \
    xargs -I {} bash -c "${code_server_module_home}/code-server --install-extension {}" && \

# code server config
    mkdir -p ${code_server_config_home}
COPY ./config/config_template.yaml ${code_server_config_home}/

# editor config
ENV font=15
ENV theme=dark
COPY ./config/settings_template.json ${code_server_config_home}/

# init script
RUN mkdir -p ${code_server_scripts_home}
COPY ./scripts/init-code-server.sh ${code_server_scripts_home}/
COPY ./scripts/code-server-start.sh /usr/local/bin/codeserverstart
COPY ./scripts/code-server-stop.sh /usr/local/bin/codeserverstop
COPY ./scripts/code-server-restart.sh /usr/local/bin/codeserverrestart

RUN code_server_config_home=${code_server_module_home}/config && \
    code_server_config_file=${code_server_config_home}/config.yaml && \
    code_server_config_template_file=${code_server_config_home}/config_template.yaml && \
    sed -i "s#{code_server_config_template_file}#${code_server_config_template_file}#g" ${code_server_scripts_home}/init-code-server.sh && \
    sed -i "s#{code_server_config_file}#${code_server_config_file}#g" ${code_server_scripts_home}/init-code-server.sh && \
    sed -i "s#{code_server_config_home}#${code_server_config_home}#g" ${code_server_scripts_home}/init-code-server.sh && \

    sed -i "s#{code_server_module_home}#${code_server_module_home}#g" /usr/local/bin/codeserverstart && \
    sed -i "s#{code_server_config_file}#${code_server_config_file}#g" /usr/local/bin/codeserverstart && \
    sed -i "s#{code_server_log}#${code_server_log}#g" /usr/local/bin/codeserverstart && \
    chmod +x /usr/local/bin/codeserverstart && chmod +x /usr/local/bin/codeserverstop && chmod +x /usr/local/bin/codeserverrestart && \

    echo "sh ${code_server_scripts_home}/init-code-server.sh && codeserverstart" >> /init_service

# log
RUN mkdir -p ${code_server_log_home}
RUN addlogrotate ${code_server_log} code_server