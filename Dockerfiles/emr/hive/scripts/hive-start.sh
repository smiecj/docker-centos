#!/bin/bash

## wait for namenode
namenode=`echo ${DEFAULTFS} | sed "s#hdfs://#http://#g"`
while :
do
    curl_ret=`curl ${namenode}`
    namenode_connect_ret=$?
    if [[ 0 == ${namenode_connect_ret} ]]; then
        echo "namenode has start"
        break
    else
        echo "namenode has not start, will wait for it"
        sleep 3
    fi
done

nohup {hive_module_home}/bin/hive --service metastore >> {hive_metastore_log} 2>&1 &

nohup {hive_module_home}/bin/hive --service hiveserver2 --hiveconf hive.root.logger=INFO,console >> {hive_hiveserver2_log} 2>&1 &