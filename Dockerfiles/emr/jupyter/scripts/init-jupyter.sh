#!/bin/bash

if [[ "notebook" == "$component" ]]; then
    sed -i "s/c.Spawner.cmd = .*/c.Spawner.cmd = \['jupyterhub-singleuser'\]/g" {jupyter_config_home}/jupyterhub_config.py
    sed -i "s/export JUPYTERHUB_SINGLEUSER_APP=.*/export JUPYTERHUB_SINGLEUSER_APP=\"notebook.notebookapp.NotebookApp\"/g" /etc/profile
elif [[ "lab" == "$component" ]]; then
    sed -i "s/c.Spawner.cmd = .*/c.Spawner.cmd = \['jupyter-labhub'\]/g" {jupyter_config_home}/jupyterhub_config.py
    sed -i "s/export JUPYTERHUB_SINGLEUSER_APP=.*/export JUPYTERHUB_SINGLEUSER_APP=\"jupyter_server.serverapp.ServerApp\"/g" /etc/profile
fi

## lab2: no need to set JUPYTERHUB_SINGLEUSER_APP
lab_version=`jupyter-lab --version`
if [[ $lab_version =~ 2.* ]]; then
    sed -i "s/export JUPYTERHUB_SINGLEUSER_APP=.*/export JUPYTERHUB_SINGLEUSER_APP=\"\"/g" /etc/profile
fi