ARG IMAGE_BASE
FROM ${IMAGE_BASE} AS base

USER root

ARG GO_VERSION

# install golang
ARG repo_home
ARG go_home=/usr/golang
ARG go_repo_home=${repo_home}/go
ARG go_proxy
ARG go_pkg_repo

ARG TARGETARCH
RUN mkdir -p ${go_home} && mkdir -p ${go_repo_home} && \
    go_pkg=go${GO_VERSION}.linux-${TARGETARCH}.tar.gz && \
    go_pkg_download_url=${go_pkg_repo}/${go_pkg} && \
    cd ${go_home} && curl -LO ${go_pkg_download_url} && tar -xzvf ${go_pkg} && rm ${go_pkg} && \

## profile
    echo -e '\n# go' >> /etc/profile && \
    echo "export GOROOT=$go_home/go" >> /etc/profile && \
    echo "export GOPATH=$go_repo_home" >> /etc/profile && \
    echo "export GOPROXY=$go_proxy" >> /etc/profile && \
    echo 'export PATH=$PATH:$GOROOT/bin:$GOPATH/bin' >> /etc/profile && \

## config: goproxy (if needed)
    source /etc/profile && go env -w GOPROXY=${go_proxy}