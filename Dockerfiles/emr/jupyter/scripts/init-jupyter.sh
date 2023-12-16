#!/bin/bash

config_file={jupyter_config_home}/jupyterhub_config.py

if [[ "notebook" == "$component" ]]; then
    sed -i "s/c.Spawner.cmd = .*/c.Spawner.cmd = \['jupyterhub-singleuser'\]/g" ${config_file}
    sed -i "s/export JUPYTERHUB_SINGLEUSER_APP=.*/export JUPYTERHUB_SINGLEUSER_APP=\"notebook.notebookapp.NotebookApp\"/g" /etc/profile
elif [[ "lab" == "$component" ]]; then
    sed -i "s/c.Spawner.cmd = .*/c.Spawner.cmd = \['jupyter-labhub'\]/g" ${config_file}
    sed -i "s/export JUPYTERHUB_SINGLEUSER_APP=.*/export JUPYTERHUB_SINGLEUSER_APP=\"jupyter_server.serverapp.ServerApp\"/g" /etc/profile
fi

## lab2: no need to set JUPYTERHUB_SINGLEUSER_APP
lab_version=`jupyter-lab --version`
if [[ $lab_version =~ 2.* ]]; then
    sed -i "s/export JUPYTERHUB_SINGLEUSER_APP=.*/export JUPYTERHUB_SINGLEUSER_APP=\"\"/g" /etc/profile
fi

## proxy
sed -i "s#^c.ConfigurableHTTPProxy.auth_token = .*#c.ConfigurableHTTPProxy.auth_token = '${hub_token}'#g" ${config_file}
sed -i "s#^c.ConfigurableHTTPProxy.api_url = .*#c.ConfigurableHTTPProxy.api_url = 'http://127.0.0.1:${api_port}'#g" ${config_file}
sed -i "s#^c.ConfigurableHTTPProxy.public_url = .*#c.ConfigurableHTTPProxy.public_url = '0.0.0.0:${proxy_port}'#g" ${config_file}
sed -i "s#^export CONFIGPROXY_AUTH_TOKEN=.*#export CONFIGPROXY_AUTH_TOKEN='${hub_token}'#g" /etc/profile

## authenticator
sed -i "s/# c.JupyterHub.authenticator_class/c.JupyterHub.authenticator_class/g" ${config_file}
if [ "${auth}" == "dummy" ]; then
    sed -i "s#^c.JupyterHub.authenticator_class = .*#c.JupyterHub.authenticator_class = 'jupyterhub.auth.DummyAuthenticator'#g" ${config_file}
    sed -i "s#^c.DummyAuthenticator.password = .*#c.DummyAuthenticator.password = '${dummy_password}'#g" ${config_file}
elif [ "${auth}" == "pam" ]; then
    sed -i "s#^c.JupyterHub.authenticator_class = .*#c.JupyterHub.authenticator_class = 'jupyterhub.auth.PAMAuthenticator'#g" ${config_file}
fi