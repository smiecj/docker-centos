# common env
ARG repo_home
ARG npm_repo_home=${repo_home}/nodejs
ARG maven_home=${java_home}/maven

ARG IMAGE_NODEJS
ARG IMAGE_PYTHON
ARG IMAGE_BASE

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
