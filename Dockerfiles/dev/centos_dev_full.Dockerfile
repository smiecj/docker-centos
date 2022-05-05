# common env
ARG repo_home=/home/repo
ARG go_repo_home=$repo_home/go
ARG java_repo_home=${repo_home}/java
ARG npm_repo_home=${repo_home}/nodejs
ARG maven_version=3.8.4
ARG maven_home=/usr/java/apache-maven-${maven_version}

# java
FROM centos_java AS base_java

# golang
FROM centos_golang AS base_golang

# nodejs
FROM centos_nodejs AS base_nodejs

# python
FROM centos_python AS base_python

MAINTAINER smiecj smiecj@github.com

ARG ROOT_PWD=root!centos123

USER root

# base
FROM centos_base AS base

## copy java, maven, package
### 参考: https://stackoverflow.com/a/53682110
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

## copy golang package
ARG repo_home
ARG go_repo_home
ARG go_home=/usr/golang
RUN mkdir -p {go_home} && mkdir -p ${go_repo_home}
COPY --from=base_golang ${go_home}/ ${go_home}/

## go profile
COPY --from=base_golang /etc/profile /tmp/profile_golang
RUN sed -n '/# go/,$p' /tmp/profile_golang >> /etc/profile
RUN rm /tmp/profile_golang

## copy python (conda) package
ARG miniconda_install_path=/usr/local/miniconda
ARG conda_env_name_python3=py3
COPY --from=base_python ${miniconda_install_path} ${miniconda_install_path}

## python soft link (copy)
ARG python3_home_path=${miniconda_install_path}/envs/${conda_env_name_python3}
RUN rm -f /usr/bin/python* && rm -f /usr/bin/pip* && \
    ln -s ${python3_home_path}/bin/python3 /usr/bin/python3 && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    ln -s $python3_home_path/bin/pip3 /usr/bin/pip3 && \
    ln -s /usr/bin/pip3 /usr/bin/pip

## pip repo (copy)
RUN mkdir -p /root/.pip
COPY --from=base_python /root/.pip/pip.conf /root/.pip/

## python profile
COPY --from=base_python /etc/profile /tmp/profile_python
RUN sed -n '/# conda/,$p' /tmp/profile_python >> /etc/profile
RUN rm /tmp/profile_python

## copy npm package
ARG repo_home
ARG npm_repo_home
ARG npm_home=/usr/nodejs
RUN mkdir -p {npm_home} && mkdir -p ${npm_repo_home}
COPY --from=base_nodejs ${npm_home}/ ${npm_home}/

## mkdir npm repo folder
RUN mkdir -p $npm_repo_home/global_modules && mkdir -p $npm_repo_home/cache

## npm profile
COPY --from=base_nodejs /etc/profile /tmp/profile_nodejs
RUN sed -n '/# nodejs/,$p' /tmp/profile_nodejs >> /etc/profile
RUN rm /tmp/profile_nodejs