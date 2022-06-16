# install jupyter (notebook or lab) on default conda env
FROM centos_jupyter_base

ARG jupyter_version=3

# install jupyter
ENV component=notebook
ARG jupyter_home=/home/modules/jupyter

ARG npm_conpoment_arr="configurable-http-proxy"
ARG yum_conpoment_arr="python3-zmq python3-devel libffi libffi-devel"

## jupyter env
### local user
ARG jupyter_local_user_arr="jupyter:jupyter@Qwer jupyter_test:jupyter@test"

### proxy
ENV proxy_port=8102
ENV proxy_token=test_hub_123
ENV proxy_address=http://127.0.0.1:${proxy_port}

### jupyter & jupyterhub
ARG jupyter_module_home=/home/modules/jupyter
ARG jupyter_config_home=${jupyter_module_home}/config
ARG jupyter_scripts_home=${jupyter_module_home}/scripts

ARG jupyterhub_bind_ip=0.0.0.0
ARG jupyterhub_bind_port=8101

ARG jupyter_pam_file=jupyterhub_pam

ARG jupyter_spawner_timeout=3600
ARG jupyter_memory_limit=1G
ARG jupyter_cpu_limit=2

ARG jupyterhub_log=${jupyter_module_home}/jupyterhub.log

### pip index
ARG pip_index=http://mirrors.aliyun.com/pypi/simple/
ARG pip_index_host=mirrors.aliyun.com

## install npm conpoment
RUN source /etc/profile && for conpoment in ${npm_conpoment_arr[@]}; \
do\
    npm install -g $conpoment; \
done

## install yum component
RUN for conpoment in ${yum_conpoment_arr[@]}; \
do\
    yum -y install $conpoment; \
done

## install jupyter requirements
COPY ./requirements_jupyter*.txt /tmp/
RUN python3 -m pip install -r /tmp/requirements_jupyter_${jupyter_version}.txt --quiet --no-cache-dir -i ${pip_index} --trusted-host ${pip_index_host} -vvv
RUN rm /tmp/requirements_jupyter*.txt

## config jupyter proxy
RUN echo "export CONFIGPROXY_AUTH_TOKEN=${jupyter_proxy_token}" >> /etc/profile

## config jupyterhub
RUN mkdir -p ${jupyter_config_home} && cd ${jupyter_config_home} && \
    source /etc/profile && jupyterhub --generate-config

### basic
#### spawner
RUN sed -i 's/# c.Spawner.cmd/c.Spawner.cmd/g' ${jupyter_config_home}/jupyterhub_config.py

#### auth
RUN sed -i "s/.*c\.JupyterHub\.ip.*/c.JupyterHub.ip = '$jupyterhub_bind_ip'/g" ${jupyter_config_home}/jupyterhub_config.py
RUN sed -i "s/.*c\.JupyterHub\.port.*/c.JupyterHub.port = $jupyterhub_bind_port/g" ${jupyter_config_home}/jupyterhub_config.py
RUN echo -e "\nc.PAMAuthenticator.service = '$jupyter_pam_file'\n" >> ${jupyter_config_home}/jupyterhub_config.py
ARG jupyter_pam_path=/etc/pam.d/${jupyter_pam_file}
COPY ./jupyterhub_pam ${jupyter_pam_path}

### culler
RUN echo -e "import sys\n\
c.JupyterHub.services = [\n\
    {\n\
        'name': 'idle-culler',\n\
        'admin': True,\n\
        'command': [\n\
            sys.executable,\n\
            '-m', 'jupyterhub_idle_culler',\n\
            '--timeout=${jupyter_spawner_timeout}'\n\
        ],\n\
    }\n\
]" >> ${jupyter_config_home}/jupyterhub_config.py

### scala
RUN echo -e "c.Spawner.environment = {\n\
        'SPARK_HOME': '/home/modules/spark-3.1.2'\n\
}" >> ${jupyter_config_home}/jupyterhub_config.py

### R
# RUN yum -y install epel-release
# RUN yum -y update
# RUN yum -y install R

### memory and cpu limit
RUN echo -e """# resource limit\n\
c.Spawner.mem_limit = \"${jupyter_memory_limit}\"\n\
c.Spawner.cpu_limit = ${jupyter_cpu_limit}\n""" >> ${jupyter_config_home}/jupyterhub_config.py

### proxy
RUN echo -e "# proxy \n\
c.JupyterHub.cleanup_servers = False\n\
c.ConfigurableHTTPProxy.should_start = False\n\
c.ConfigurableHTTPProxy.auth_token = '${proxy_token}'\n\
c.ConfigurableHTTPProxy.api_url = '${proxy_address}'\n\
" >> ${jupyter_config_home}/jupyterhub_config.py

## install some basic extensions
RUN source /etc/profile && jupyter contrib nbextension install --sys-prefix && \
    jupyter nbextension enable hinterland/hinterland --sys-prefix && \
    jupyter nbextension enable execute_time/ExecuteTime --sys-prefix && \
    jupyter nbextension enable snippets/main --sys-prefix 

### lsp
RUN pip3 install git+https://github.com/krassowski/python-language-server.git@main

## add at least two local account
RUN for user_info in ${jupyter_local_user_arr[@]}; \
do\
    user_info_arr=($(echo $user_info | tr ":" "\n")) && \
    useradd ${user_info_arr[0]} && \
    echo "${user_info_arr[0]}:${user_info_arr[1]}" | chpasswd && \
    ### add extension default config
    #### lsp: auto hint
    lsp_user_conf_home=/home/${user_info_arr[0]}/.jupyter/lab/user-settings/@krassowski/jupyterlab-lsp && \
    mkdir -p ${lsp_user_conf_home} && \
    echo -e """{\n\
        \"continuousHinting\": true\n\
    }""" > ${lsp_user_conf_home}/completion.jupyterlab-settings && \
    chown -R jupyter:jupyter /home/${user_info_arr[0]}/.jupyter; \
done

## profile & init script
RUN echo -e """\n\
# jupyter\n\
export JUPYTERHUB_SINGLEUSER_APP=notebook.notebookapp.NotebookApp\n\
""" >> /etc/profile
RUN mkdir -p ${jupyter_scripts_home}
COPY ./scripts/init-jupyter.sh ${jupyter_scripts_home}/
RUN sed -i "s#{jupyter_config_home}#${jupyter_config_home}#g" ${jupyter_scripts_home}/init-jupyter.sh

## copy jupyter start and stop script
COPY ./scripts/jupyter-start.sh /usr/local/bin/jupyterstart
COPY ./scripts/jupyter-stop.sh /usr/local/bin/jupyterstop
COPY ./scripts/jupyter-restart.sh /usr/local/bin/jupyterrestart
RUN sed -i "s#{jupyter_config_home}#${jupyter_config_home}#g" /usr/local/bin/jupyterstart && \
    sed -i "s#{jupyterhub_log}#${jupyterhub_log}#g" /usr/local/bin/jupyterstart && \
    chmod +x /usr/local/bin/jupyterstart && chmod +x /usr/local/bin/jupyterstop && chmod +x /usr/local/bin/jupyterrestart

## init script
RUN echo "sh ${jupyter_scripts_home}/init-jupyter.sh && jupyterstart" >> /init_service

## jupyterhub log rotate
RUN addlogrotate $jupyterhub_log jupyterhub
