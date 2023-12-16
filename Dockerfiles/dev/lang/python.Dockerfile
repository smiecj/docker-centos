ARG IMAGE_BASE
FROM ${IMAGE_BASE} AS base

USER root

# install python
ARG miniconda_install_path=/usr/local/miniconda
ARG conda_env_name_python3=py3
ARG python3_version
ARG python3_tag
ARG condarc_file
COPY ./conda/condarc* ${HOME}/

ARG github_url
ARG pip_repo

# init repo
COPY ./scripts/init_python_repo /
COPY ./conda/ ${HOME}/

## download conda
ARG CONDA_FORGE_VERSION
ARG TARGETARCH
RUN miniforge_url="${github_url}/conda-forge/miniforge/releases/download" && \
    conda_install_script=miniforge_install.sh && \
    if [ "amd64" == "${TARGETARCH}" ]; then arch="x86_64"; else arch="aarch64"; fi && \
    conda_forge_download_url=${miniforge_url}/${CONDA_FORGE_VERSION}/Miniforge3-${CONDA_FORGE_VERSION}-Linux-${arch}.sh && \
    echo "miniforge download url: $conda_forge_download_url" && \
    curl -L $conda_forge_download_url -o ${conda_install_script} && \
    bash $conda_install_script -b -p ${miniconda_install_path} && rm -f ${conda_install_script} && \

## create default python env
    $miniconda_install_path/bin/conda create -y --name ${conda_env_name_python3} python=${python3_version} && \
    $miniconda_install_path/bin/conda config --set auto_activate_base false && \

## profile
    python3_home_path=${miniconda_install_path}/envs/${conda_env_name_python3} && \
    python3_lib_path=${miniconda_install_path}/envs/${conda_env_name_python3}/lib/python${python3_tag}/site-packages && \
    echo -e "\n# conda & python" >> /etc/profile && \
    echo "export CONDA_HOME=${miniconda_install_path}" >> /etc/profile && \
    echo "export PYTHON3_HOME=${python3_home_path}" >> /etc/profile && \
    echo "export PYTHON3_LIB_HOME=${python3_lib_path}" >> /etc/profile && \
    echo "export PATH=\$PATH:\$PYTHON3_HOME/bin:\$CONDA_HOME/bin" >> /etc/profile && \

## python soft link
    yum -y remove python3 && \
    rm -f /usr/bin/pip* && \
    ln -s ${python3_home_path}/bin/python3 /usr/bin/python3 && \
    ln -s $python3_home_path/bin/pip3 /usr/bin/pip3 && \
    ln -s /usr/bin/pip3 /usr/bin/pip && \

## pip repo
    cd ~ && mkdir -p .pip && cd .pip && rm -f pip.conf && \
    echo '[global]' >> pip.conf && \
    echo "index-url = ${pip_repo}" >> pip.conf