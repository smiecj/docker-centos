# base image for compile java
# common env
ARG repo_home=/home/repo
ARG go_repo_home=$repo_home/go
ARG java_repo_home=${repo_home}/java
ARG npm_repo_home=${repo_home}/nodejs
ARG maven_version=3.8.4
ARG maven_home=/usr/java/apache-maven-${maven_version}

ARG JAVA_IMAGE
ARG NODEJS_IMAGE
ARG MINIMAL_IMAGE_7

# java
FROM ${JAVA_IMAGE} AS base_java

# nodejs
FROM ${NODEJS_IMAGE} AS base_nodejs

# minimal
FROM ${MINIMAL_IMAGE_7} AS base

MAINTAINER smiecj smiecj@github.com

USER root
ENV HOME /root

# java

## copy java, maven, package
ARG repo_home
ARG java_repo_home
ARG java_home=/usr/java
ARG maven_repo=${java_repo_home}/maven
RUN mkdir -p ${java_home} && mkdir -p ${java_repo_home}
COPY --from=base_java ${java_home}/ ${java_home}/

## init maven repo
ARG default_maven_repo_home=.m2
ARG default_maven_repo_path=${default_maven_repo_home}/repository
RUN cd ~ && mkdir -p $default_maven_repo_home
RUN cd ~ && rm -rf ${default_maven_repo_path} && mkdir -p ${maven_repo} && mkdir -p ${default_maven_repo_home} && ln -s ${maven_repo} ${default_maven_repo_path}
RUN cd ~ && rm -f ${default_maven_repo_home}/settings.xml && ln -s ${maven_home}/conf/settings.xml ${default_maven_repo_home}/settings.xml

## java profile
COPY --from=base_java /etc/profile /tmp/profile_java
RUN sed -n '/# java/,$p' /tmp/profile_java >> /etc/profile
RUN rm /tmp/profile_java

# nodejs

## copy npm package
ARG repo_home
ARG npm_repo_home
ARG npm_home=/usr/nodejs
RUN mkdir -p {npm_home} && mkdir -p ${npm_repo_home}
COPY --from=base_nodejs ${npm_home}/ ${npm_home}/

## mkdir npm repo folder
RUN mkdir -p $npm_repo_home/global_modules && mkdir -p $npm_repo_home/cache

## npm config and profile
COPY --from=base_nodejs $HOME/.npmrc $HOME/
COPY --from=base_nodejs /etc/profile /tmp/profile_nodejs
RUN sed -n '/# nodejs/,$p' /tmp/profile_nodejs >> /etc/profile
RUN rm /tmp/profile_nodejs
