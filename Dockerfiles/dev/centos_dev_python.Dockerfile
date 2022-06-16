FROM centos_base AS base

MAINTAINER smiecj smiecj@github.com

USER root

# install python

## fix: conda version from repo
## ARG conda_forge_version=4.12.0-0
ARG conda_install_script=miniforge_install.sh

ARG miniconda_install_path="/usr/local/miniconda"
ARG conda_env_key_home="CONDA_HOME"
ARG python3_env_key_home="PYTHON3_HOME"
ARG python3_lib_key_home="PYTHON3_LIB_HOME"

ARG conda_env_name_python3=py3
ARG python3_version=3.8

ARG pip_repo="https://pypi.mirrors.ustc.edu.cn/simple/"

COPY env_python.sh /tmp

## download conda

RUN . /tmp/env_python.sh && curl -L $conda_forge_download_url -o ${conda_install_script} && \
    bash $conda_install_script -b -p ${miniconda_install_path} && rm -f ${conda_install_script}

## create default python env
RUN $miniconda_install_path/bin/conda create -y --name ${conda_env_name_python3} python=${python3_version}
RUN $miniconda_install_path/bin/conda config --set auto_activate_base false

## profile
ARG python3_home_path=${miniconda_install_path}/envs/${conda_env_name_python3}
ARG python3_lib_path=${miniconda_install_path}/envs/${conda_env_name_python3}/lib/python${python3_version}/site-packages
RUN echo -e "\n# conda & python" >> /etc/profile && \
    echo "export $conda_env_key_home=$miniconda_install_path" >> /etc/profile && \
    echo "export $python3_env_key_home=$python3_home_path" >> /etc/profile && \
    echo "export $python3_lib_key_home=$python3_lib_path" >> /etc/profile && \
    echo "export PATH=\$PATH:\$$python3_env_key_home/bin:\$$conda_env_key_home/bin" >> /etc/profile

## python soft link
RUN rm -f /usr/bin/python* && rm -f /usr/bin/pip* && \
    ln -s ${python3_home_path}/bin/python3 /usr/bin/python3 && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    ln -s $python3_home_path/bin/pip3 /usr/bin/pip3 && \
    ln -s /usr/bin/pip3 /usr/bin/pip

## pip repo
RUN cd ~ && mkdir -p .pip && cd .pip && rm -f pip.conf && \
    echo '[global]' >> pip.conf && \
    echo "index-url = ${pip_repo}" >> pip.conf

RUN rm -f /tmp/env_python.sh
