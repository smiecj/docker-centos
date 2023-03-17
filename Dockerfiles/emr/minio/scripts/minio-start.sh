#!/bin/bash

pushd {minio_module_home}

mkdir -p ${DATA_HOME}

export MINIO_ACCESS_KEY=${ACCESS_KEY}
export MINIO_SECRET_KEY=${SECRET_KEY}
export MINIO_ROOT_USER=${ROOT_USER}
export MINIO_ROOT_PASSWORD=${ROOT_PASSWORD}

nohup minio server ${DATA_HOME} --address :${PORT} --console-address :${WEB_PORT} > {minio_log} 2>&1 &

popd