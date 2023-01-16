# common env
ARG repo_home
ARG npm_repo_home=${repo_home}/nodejs
ARG go_repo_home=${repo_home}/go

ARG IMAGE_GO
ARG IMAGE_NODEJS
ARG IMAGE_BASE

# java
FROM ${IMAGE_GO} AS base_golang

# nodejs
FROM ${IMAGE_NODEJS} AS base_nodejs

USER root
ENV HOME /root

# base
FROM ${IMAGE_BASE} AS base

# nodejs

## copy npm package
ARG repo_home
ARG npm_repo_home
ARG npm_home=/usr/nodejs
RUN mkdir -p ${npm_home} && mkdir -p ${npm_repo_home}
COPY --from=base_nodejs ${npm_home}/ ${npm_home}/
COPY --from=base_nodejs $HOME/.npmrc $HOME/
COPY --from=base_nodejs /etc/profile /tmp/profile_nodejs


RUN mkdir -p ${npm_repo_home}/global_modules && mkdir -p ${npm_repo_home}/cache && \

## npm config and profile
    sed -n '/# nodejs/,$p' /tmp/profile_nodejs >> /etc/profile && \
    rm /tmp/profile_nodejs

# go

## copy golang package
ARG go_repo_home
ARG go_home=/usr/golang
RUN mkdir -p {go_home} && mkdir -p ${go_repo_home}
COPY --from=base_golang ${go_home}/ ${go_home}/

## go profile
COPY --from=base_golang /etc/profile /tmp/profile_golang
RUN sed -n '/# go/,$p' /tmp/profile_golang >> /etc/profile && \
    rm /tmp/profile_golang