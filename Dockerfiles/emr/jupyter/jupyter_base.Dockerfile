# base image for compile jupyter
# common env
ARG repo_home=/home/repo
ARG go_repo_home=$repo_home/go
ARG npm_repo_home=${repo_home}/nodejs

# nodejs
FROM centos_nodejs AS base_nodejs

# python
FROM centos_python AS base_python

# base
FROM centos_base AS base

MAINTAINER smiecj smiecj@github.com

USER root
ENV HOME /root

# python

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
