#!/bin/bash

source /etc/profile

pushd {jupyter_home}

nohup jupyterhub --config {jupyter_config_home}/jupyterhub_config.py >> {jupyterhub_log} 2>&1 &

popd