#!/bin/bash

pushd {flink_module_home}/conf

cp flink-conf-example.yaml flink-conf.yaml

sed -i "s#{rest_port}#${rest_port}#g" flink-conf.yaml
sed -i "s#{jobmanager_host}#${jobmanager_host}#g" flink-conf.yaml
sed -i "s#{jobmanager_port}#${jobmanager_port}#g" flink-conf.yaml

if [[ -n "${workers}" ]]; then
    rm -f workers
    worker_list=($(echo ${workers} | tr "," "\n" | uniq))
    for current_worker in "${worker_list[@]}"; do
        echo "${current_worker}" >> workers
    done
fi

if [[ -n "${masters}" ]]; then
    rm -f masters
    master_list=($(echo ${masters} | tr "," "\n" | uniq))
    for current_master in "${master_list[@]}"; do
        echo "${current_master}" >> masters
    done
fi

popd