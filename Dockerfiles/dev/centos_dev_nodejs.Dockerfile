FROM centos_base AS base

MAINTAINER smiecj smiecj@github.com

ARG ROOT_PWD=root!centos123

USER root

# install nodejs
ARG node_version=v14.17.0
ARG repo_home=/home/repo
ARG npm_home=/usr/nodejs
ARG npm_repo_home=${repo_home}/nodejs
ARG npm_remote_repo="https://registry.npm.taobao.org"

COPY env_nodejs.sh /tmp/

RUN . /tmp/env_nodejs.sh && mkdir -p ${npm_home} && mkdir -p ${npm_repo_home} && \
    cd ${npm_home} && curl -LO $npm_download_url && tar -xzvf $npm_pkg && rm -f $npm_pkg

## profile
RUN . /tmp/env_nodejs.sh && echo -e '\n# nodejs' >> /etc/profile && \
    echo "export NODE_HOME=$npm_home/$npm_folder" >> /etc/profile && \
    echo "export NODE_REPO=$npm_repo_home/global_modules" >> /etc/profile  && \
    echo 'export PATH=$PATH:$NODE_HOME/bin:$NODE_REPO/bin' >> /etc/profile

RUN . /tmp/env_nodejs.sh && npm_config=${npm_home}/$npm_folder/lib/node_modules/npm/.npmrc && \
    echo "prefix = $npm_repo_home/global_modules" >> $npm_config && \
    echo "cache = $npm_repo_home/cache" >> $npm_config && \
    echo "registry = ${npm_remote_repo}" >> $npm_config

RUN rm -f /tmp/env_nodejs.sh
