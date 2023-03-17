ARG IMAGE_BASE
FROM ${IMAGE_BASE} AS base

USER root
ENV HOME /root

# install nodejs
## history version: https://nodejs.org/en/download/releases/
ARG NODEJS_VERSION
ARG repo_home
ARG npm_home=/usr/nodejs
ARG npm_repo_home=${repo_home}/nodejs
ARG npm_mirror
ARG nodejs_repo

ARG preinstall_component="yarn vue-cli react-cli"

# init repo
COPY ./scripts/init_nodejs_repo /

## install
ARG TARGETARCH
RUN if [ "amd64" == "${TARGETARCH}" ]; then arch="x64"; else arch=${TARGETARCH}; fi && \
    npm_folder=node-${NODEJS_VERSION}-linux-${arch} && \
    npm_pkg=${npm_folder}.tar.gz && \
    npm_download_url=${nodejs_repo}/${NODEJS_VERSION}/${npm_pkg} && \
    mkdir -p ${npm_home} && mkdir -p ${npm_repo_home} && \
    cd ${npm_home} && curl -LO ${npm_download_url} && tar -xzvf ${npm_pkg} && rm -f ${npm_pkg} && \
    mv ${npm_folder}/* ./ && rm -r ${npm_folder} && \

## profile
    echo -e '\n# nodejs' >> /etc/profile && \
    echo "export NODE_HOME=${npm_home}" >> /etc/profile && \
    echo "export NODE_REPO=${npm_repo_home}/global_modules" >> /etc/profile  && \
    echo 'export PATH=$PATH:$NODE_HOME/bin:$NODE_REPO/bin' >> /etc/profile && \

    echo "prefix = ${npm_repo_home}/global_modules" >> $HOME/.npmrc && \
    echo "cache = ${npm_repo_home}/cache" >> $HOME/.npmrc && \
    echo "registry = ${npm_mirror}" >> $HOME/.npmrc && \
    mkdir -p ${npm_repo_home}/global_modules && \
    mkdir -p ${npm_repo_home}/cache && \

## preinstall component
    export LD_LIBRARY_PATH=/usr/local/lib:/usr/lib:/usr/local/lib64:/usr/lib64 && \
    source /etc/profile && for conpoment in ${preinstall_component[@]}; \
do\
    npm install -g $conpoment; \
done