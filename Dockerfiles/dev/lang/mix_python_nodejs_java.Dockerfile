# common env
ARG repo_home
ARG npm_repo_home=${repo_home}/nodejs
ARG java_repo_home=${repo_home}/java
ARG maven_home=${java_home}/maven

ARG IMAGE_JAVA
ARG IMAGE_NODEJS
ARG IMAGE_PYTHON
ARG IMAGE_BASE

# java
FROM ${IMAGE_JAVA} AS base_java

# nodejs
FROM ${IMAGE_NODEJS} AS base_nodejs

# python
FROM ${IMAGE_PYTHON} AS base_python

USER root
ENV HOME /root

# base
FROM ${IMAGE_BASE} AS base

# python

## copy python (conda) package
ARG miniconda_install_path=/usr/local/miniconda
ARG conda_env_name_python3=py3
ARG python3_home_path=${miniconda_install_path}/envs/${conda_env_name_python3}
COPY --from=base_python ${miniconda_install_path} ${miniconda_install_path}
COPY --from=base_python /etc/profile /tmp/profile_python
COPY --from=base_python $HOME/.pip/pip.conf $HOME/.pip/
COPY --from=base_python $HOME/condarc* $HOME/

## python soft link (copy)
RUN rm /usr/bin/pip* && \
    rm -f /usr/bin/python3* && \
    ln -s ${python3_home_path}/bin/python3 /usr/bin/python3 && \
    ln -s $python3_home_path/bin/pip3 /usr/bin/pip3 && \
    ln -s /usr/bin/pip3 /usr/bin/pip && \

## pip repo (copy)
    mkdir -p $HOME/.pip && \

## python profile
    sed -n '/# conda/,$p' /tmp/profile_python >> /etc/profile && \
    rm /tmp/profile_python

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

# java
ARG repo_home
ARG java_repo_home
ARG java_home=/usr/java
ARG maven_repo=${java_repo_home}/maven
ARG default_maven_repo_home=.m2
ARG default_maven_repo_path=${default_maven_repo_home}/repository
RUN mkdir -p ${java_home} && mkdir -p ${java_repo_home}
COPY --from=base_java ${java_home}/ ${java_home}/
COPY --from=base_java /etc/profile /tmp/profile_java

## init maven repo
RUN cd ~ && mkdir -p $default_maven_repo_home && \
    cd ~ && rm -rf ${default_maven_repo_path} && mkdir -p ${maven_repo} && mkdir -p ${default_maven_repo_home} && ln -s ${maven_repo} ${default_maven_repo_path} && \
    cd ~ && rm -f ${default_maven_repo_home}/settings.xml && ln -s ${maven_home}/conf/settings.xml ${default_maven_repo_home}/settings.xml && \

## java profile
    sed -n '/# java/,$p' /tmp/profile_java >> /etc/profile && \
    rm /tmp/profile_java