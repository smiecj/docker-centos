FROM ${DEV_FULL_IMAGE}

ARG TARGETARCH

ARG code_server_short_version=4.5.1
ARG code_server_tag=v${code_server_short_version}
ARG code_server_code_url=https://github.com/coder/code-server
ARG module_home=/opt/modules
ARG code_server_module_home=/opt/modules/code_server
ARG code_server_log_home=/var/log/code-server
ARG code_server_log=${code_server_log_home}/code-server.log
ARG code_server_config_home=${code_server_module_home}/config
ARG code_server_config_file=${code_server_config_home}/config.yaml
ARG code_server_config_template_file=${code_server_config_home}/config_template.yaml
ARG code_server_scripts_home={code_server_module_home}/scripts

ARG code_server_default_extensions="vscjava.vscode-java-pack@0.25.0 hediet.vscode-drawio@1.6.4 golang.go@0.35.1 ms-python.python@2022.10.1 ms-vscode.cpptools-themes@1.0.0"

ARG code_server_download_url_prefix=https://github.com/coder/code-server/releases/download

ENV PORT=8080
ENV PASSWORD=test_code_server

# env
## node v16.15.1
### refer: https://github.com/microsoft/vscode-ripgrep/issues/26#issuecomment-1146735036

## yum
RUN yum -y install pkgconfig libX11-devel libsecret-devel
RUN dnf -y --enablerepo=powertools install libxkbfile-devel

## gcc 5.*
### refer: https://stackoverflow.com/a/39871325
# ARG gcc_version=5.5.0
# ARG gcc_download_url_prefix=https://mirrors.tuna.tsinghua.edu.cn/gnu/gcc
# ARG gcc_download_url_prefix=http://ftp.gnu.org/gnu/gcc
# RUN curl -LO ${gcc_download_url_prefix}/gcc-${gcc_version}/gcc-${gcc_version}.tar.gz && \
#     tar -xvf gcc-${gcc_version}.tar.gz && cd gcc-${gcc_version} && \
#     ./contrib/download_prerequisites && mkdir build && \
#     cd build && ../configure -prefix=/usr/local --enable-checking=release --enable-languages=c,c++ --disable-multilib && \
#     make && make install

# compile code-server
## todo: fix argon2 compile problem
## https://github.com/ranisalt/node-argon2/issues/331
RUN cd /tmp && git clone ${code_server_code_url} && cd code_server && git checkout tags/${code_server_tag} && \
    git clone https://github.com/microsoft/vscode lib/vscode && \
    source /etc/profile && npm -g install yarn typescript && \
    unset http_proxy && unset https_proxy && \
    yarn install && yarn release:standalone && yarn package

# move package to module folder
RUN mkdir -p ${code_server_module_home}

# install code-server default plugins
RUN for extension in ${code_server_default_extensions[@]}; \
do\
    ${code_server_module_home}/code-server --install-extension $extension; \
done

# code server config
RUN mkdir -p ${code_server_config_home}
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

RUN sed -i "s#{code_server_config_template_file}#${code_server_config_template_file}#g" ${code_server_scripts_home}/init-code-server.sh && \
    sed -i "s#{code_server_config_file}#${code_server_config_file}#g" ${code_server_scripts_home}/init-code-server.sh && \
    sed -i "s#{code_server_config_home}#${code_server_config_home}#g" ${code_server_scripts_home}/init-code-server.sh

RUN sed -i "s#{code_server_module_home}#${code_server_module_home}#g" /usr/local/bin/codeserverstart && \
    sed -i "s#{code_server_config_file}#${code_server_config_file}#g" /usr/local/bin/codeserverstart && \
    sed -i "s#{code_server_log}#${code_server_log}#g" /usr/local/bin/codeserverstart && \
    chmod +x /usr/local/bin/codeserverstart && chmod +x /usr/local/bin/codeserverstop && chmod +x /usr/local/bin/codeserverrestart

RUN echo "sh ${code_server_scripts_home}/init-code-server.sh && codeserverstart" >> /init_service

# log
RUN mkdir -p ${code_server_log_home}
RUN addlogrotate ${code_server_log} code_server