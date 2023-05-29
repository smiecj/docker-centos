#!/bin/bash

param=""

if [ -n "${FE_MASTER_HOST}" ]; then
    param="$param --helper ${FE_MASTER_HOST}:9010"
fi

{starrocks_fe_module_home}/bin/start_fe.sh ${param} --daemon