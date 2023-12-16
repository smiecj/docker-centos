# install jupyter (notebook or lab) on default conda env
ARG IMAGE_JUPYTER_BASE
FROM ${IMAGE_JUPYTER_BASE}

ARG jupyter_version
ARG module_home
ARG pip_repo
ARG github_url

# install jupyter
ENV component=notebook

### proxy
ENV api_port=8102
ENV proxy_port=8000
ENV hub_token=test_hub_123

### authenticator
ENV auth="dummy"
ENV dummy_password="jupyter@Qwer"

# copy script and config
COPY ./scripts/init-jupyter.sh /tmp
COPY ./scripts/jupyter-start.sh /usr/local/bin/jupyterstart
COPY ./scripts/jupyter-stop.sh /usr/local/bin/jupyterstop
COPY ./scripts/jupyter-restart.sh /usr/local/bin/jupyterrestart
COPY ./requirements_jupyter*.txt /tmp/
COPY ./jupyterhub_pam /tmp

RUN jupyter_home=${module_home}/jupyter && \
    npm_conpoment_arr="configurable-http-proxy" && \
    yum_conpoment_arr="libffi libffi-devel" && \

    jupyter_module_home=${module_home}/jupyter && \
    jupyter_config_home=${jupyter_module_home}/config && \
    jupyter_scripts_home=${jupyter_module_home}/scripts && \

    jupyter_pam_file=jupyterhub_pam && \
    jupyter_spawner_timeout=3600 && \
    jupyter_memory_limit=1G && \
    jupyter_cpu_limit=2 && \

    jupyterhub_log=${jupyter_module_home}/jupyterhub.log && \

### local user
    jupyter_local_user_arr="jupyter:jupyter@Qwer jupyter_test:jupyter@test" && \


## install npm conpoment
source /etc/profile && for conpoment in ${npm_conpoment_arr[@]}; \
do\
    npm install -g $conpoment; \
done && \

## install yum component
for conpoment in ${yum_conpoment_arr[@]}; \
do\
    yum -y install $conpoment; \
done && \

## install jupyter requirements
pip3 install jupyter-packaging && \
python3 -m pip install -r /tmp/requirements_jupyter_${jupyter_version}.txt --quiet --no-cache-dir -i ${pip_repo} -vvv && \
rm /tmp/requirements_jupyter*.txt && \

## config jupyter proxy
echo "export CONFIGPROXY_AUTH_TOKEN=" >> /etc/profile && \

## config jupyterhub
mkdir -p ${jupyter_config_home} && cd ${jupyter_config_home} && \
source /etc/profile && jupyterhub --generate-config && \

### basic
#### spawner
sed -i 's/# c.Spawner.cmd/c.Spawner.cmd/g' ${jupyter_config_home}/jupyterhub_config.py && \

#### auth
echo -e "\nc.PAMAuthenticator.service = '$jupyter_pam_file'\n" >> ${jupyter_config_home}/jupyterhub_config.py && \
jupyter_pam_path=/etc/pam.d/${jupyter_pam_file} && mv /tmp/jupyterhub_pam ${jupyter_pam_path} && \

### culler
echo -e "import sys\n\
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
]" >> ${jupyter_config_home}/jupyterhub_config.py && \

### scala
echo -e "c.Spawner.environment = {\n\
        'SPARK_HOME': '/home/modules/spark-3.1.2'\n\
}" >> ${jupyter_config_home}/jupyterhub_config.py && \

### R
# RUN yum -y install epel-release
# RUN yum -y update
# RUN yum -y install R

### memory and cpu limit
echo -e """# resource limit\n\
c.Spawner.mem_limit = \"${jupyter_memory_limit}\"\n\
c.Spawner.cpu_limit = ${jupyter_cpu_limit}\n""" >> ${jupyter_config_home}/jupyterhub_config.py && \

### proxy
echo -e "# proxy \n\
c.JupyterHub.cleanup_servers = False\n\
c.ConfigurableHTTPProxy.should_start = True\n\
c.ConfigurableHTTPProxy.auth_token = ''\n\
c.ConfigurableHTTPProxy.api_url = ''\n\
c.ConfigurableHTTPProxy.public_url = ''\n\
" >> ${jupyter_config_home}/jupyterhub_config.py && \

### dummy
echo -e "# dummy \n\
c.DummyAuthenticator.password = ''\n\
" >> ${jupyter_config_home}/jupyterhub_config.py && \

### jupyterlab-code-formatter
#### https://jupyterlab-code-formatter.readthedocs.io/custom-formatter.html#adding-custom-formatters
echo -e """\n\
from jupyterlab_code_formatter.formatters import BaseFormatter, handle_line_ending_and_magic, SERVER_FORMATTERS\n\
class ExampleCustomFormatter(BaseFormatter):\n\
\n\
    label = \"Apply Example Custom Formatter\"\n\
\n\
    @property\n\
    def importable(self) -> bool:\n\
        return True\n\
\n\
    @handle_line_ending_and_magic\n\
    def format_code(self, code: str, notebook: bool, **options) -> str:\n\
        return \"42\"\n\
\n\
SERVER_FORMATTERS[\"example\"] = ExampleCustomFormatter()\n\
""" >> ${jupyter_config_home}/jupyterhub_config.py && \

## install some basic extensions
if [ "4" != "${jupyter_version}" ]; \
then\
    source /etc/profile && jupyter contrib nbextension install --sys-prefix && \
    jupyter nbextension enable hinterland/hinterland --sys-prefix && \
    jupyter nbextension enable execute_time/ExecuteTime --sys-prefix && \
    jupyter nbextension enable snippets/main --sys-prefix;\
fi && \

### lsp
source /etc/profile && if [ "2" == "${jupyter_version}" ]; \
then\
    jupyter labextension install @krassowski/jupyterlab-lsp@2.1.4;\
fi && \
if [ "4" != "${jupyter_version}" ]; \
then\
    pip3 install 'python-language-server[all]';\
fi && \

## add local account and set default extension config
for user_info in ${jupyter_local_user_arr[@]}; \
do\
    user_info_arr=($(echo $user_info | tr ":" "\n")) && \
    current_user_name=${user_info_arr[0]} && \
    current_user_pwd=${user_info_arr[1]} && \
    useradd ${current_user_name} && \
    echo "${current_user_name}:${current_user_pwd}" | chpasswd && \
    ### add extension default config
    user_settings_path_prefix=/home/${current_user_name}/.jupyter/lab/user-settings && \
    #### lsp: auto hint
    lsp_user_conf_home=${user_settings_path_prefix}/@krassowski/jupyterlab-lsp && \
    mkdir -p ${lsp_user_conf_home} && \
    echo -e """{\n\
        \"continuousHinting\": true\n\
    }""" > ${lsp_user_conf_home}/completion.jupyterlab-settings && \

    #### dark theme
    apputils_conf_home=${user_settings_path_prefix}/@jupyterlab/apputils-extension && \
    mkdir -p ${apputils_conf_home} && \
    echo -e """{\n\
        \"theme\": \"JupyterLab Dark\"\n\
    }""" > ${apputils_conf_home}/themes.jupyterlab-settings && \

    #### record time (lab)
    notebook_extension_home=${user_settings_path_prefix}/@jupyterlab/notebook-extension && \
    mkdir -p ${notebook_extension_home} && \
    echo -e """{\n\
    \"recordTiming\": true\n\
}""" > ${notebook_extension_home}/tracker.jupyterlab-settings && \

    #### toc auto update toc from notebook update
    toc_home=${user_settings_path_prefix}/@jupyterlab/toc-extension && \
    mkdir -p ${toc_home} && \
    echo -e """{\n\
    \"syncCollapseState\": true\n\
}""" > ${toc_home}/plugin.jupyterlab-settings && \

    #### auto format
    formatter_home=${user_settings_path_prefix}/jupyterlab_code_formatter && \
    mkdir -p ${formatter_home} && \
    echo -e """{\n\
        \"formatOnSave\": true,\n\
        \"preferences\": {\n\
            \"default_formatter\": {\n\
                \"python\": \"autopep8\"\n\
            }\n\
        }\n\
}""" > ${formatter_home}/settings.jupyterlab-settings && \

    chown -R ${current_user_name}:${current_user_name} /home/${current_user_name}/.jupyter; \
done && \

## profile & init script
echo -e """\n\
# jupyter\n\
export JUPYTERHUB_SINGLEUSER_APP=notebook.notebookapp.NotebookApp\n\
""" >> /etc/profile && \
mkdir -p ${jupyter_scripts_home} && \

mv /tmp/init-jupyter.sh ${jupyter_scripts_home} && \
sed -i "s#{jupyter_config_home}#${jupyter_config_home}#g" ${jupyter_scripts_home}/init-jupyter.sh && \

## copy jupyter start and stop script   
sed -i "s#{jupyter_config_home}#${jupyter_config_home}#g" /usr/local/bin/jupyterstart && \
sed -i "s#{jupyter_home}#${jupyter_home}#g" /usr/local/bin/jupyterstart && \
sed -i "s#{jupyterhub_log}#${jupyterhub_log}#g" /usr/local/bin/jupyterstart && \
chmod +x /usr/local/bin/jupyterstart && chmod +x /usr/local/bin/jupyterstop && chmod +x /usr/local/bin/jupyterrestart && \

## init script
echo "sh ${jupyter_scripts_home}/init-jupyter.sh && jupyterstart" >> /init_service && \
## jupyterhub log rotate
addlogrotate $jupyterhub_log jupyterhub && \
## fix-jupyterhub start failed: load notebook.base.handlers.IPythonHandler on wrong package(jupyter_server)
site_package_path=`python3 -c "import sys; print(sys.path)" | sed "s/', '/\n/g" | sed "s#\['##g" | sed "s#'\]##g" | grep site-packages | sed -n '1p'` && \
sed -i "s/if they have been imported/if they have been imported\n    '''/g" ${site_package_path}/jupyterhub/singleuser/mixins.py && \
sed -i "s/base_handlers.append(import_item(base_handler_name))/base_handlers.append(import_item(base_handler_name))\n    '''/g" ${site_package_path}/jupyterhub/singleuser/mixins.py && \
## https://github.com/ryantam626/jupyterlab_code_formatter/issues/309
sed -i "s/from functools import cache/from functools import lru_cache as cache/g" ${site_package_path}/jupyterlab_code_formatter/formatters.py