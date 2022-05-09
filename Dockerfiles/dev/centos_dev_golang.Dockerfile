FROM centos_base AS base

MAINTAINER smiecj smiecj@github.com

USER root

ARG go_version=1.18.1

# install golang
ARG repo_home=/home/repo
ARG go_home=/usr/golang
ARG go_repo_home=$repo_home/go

COPY env_golang.sh /tmp/

RUN mkdir -p ${go_home}
RUN mkdir -p ${go_repo_home}

RUN . /tmp/env_golang.sh && cd ${go_home} && curl -LO $go_download_url && tar -xzvf $go_pkg && rm -f $go_pkg

## profile
RUN echo -e '\n# go' >> /etc/profile && \
    echo "export GOROOT=$go_home/go" >> /etc/profile && \
    echo "export GOPATH=$go_repo_home" >> /etc/profile && \
    echo 'export PATH=$PATH:$GOROOT/bin:$GOPATH/bin' >> /etc/profile

## config: goproxy (if needed)
RUN source /etc/profile && go env -w GOPROXY=https://goproxy.cn,direct

RUN rm -f /tmp/env_golang.sh