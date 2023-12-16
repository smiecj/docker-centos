#!/bin/bash

pushd {spark_module_home}/conf

cp spark-defaults.conf.template spark-defaults.conf
cp spark-env.sh.template spark-env.sh

source /etc/profile

if [[ -n "${workers}" ]]; then
    rm workers
    worker_list=($(echo ${workers} | tr "," "\n" | uniq))
    for current_worker in "${worker_list[@]}"; do
        echo "${current_worker}" >> workers
    done
fi

if [[ ${SPARK_LOG_PATH} =~ ^file:.* ]]; then
    spark_log_path=`echo ${SPARK_LOG_PATH} | sed 's#file:##g'`
    mkdir -p ${spark_log_path}
fi

if [ "${SPARK_HISTORY_ENABLE}" == "true" ]; then
    export SPARK_EVENTLOG_ENABLED=true
    export SPARK_EVENTLOG_COMPRESS=true
fi

env_keys=`printenv | sed "s#=.*##g"`

for current_env_key in ${env_keys[@]}
do
    sed -i "s#{${current_env_key}}#${!current_env_key}#g" spark-env.sh
    sed -i "s#{${current_env_key}}#${!current_env_key}#g" spark-defaults.conf
done

popd