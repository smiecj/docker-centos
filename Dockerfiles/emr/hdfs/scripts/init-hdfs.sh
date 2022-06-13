#!/bin/bash

# core-site.xml
cd {hdfs_module_home}/etc/hadoop/
sed -i "s#{DEFAULTFS}#${DEFAULTFS}#g" core-site.xml
sed -i "s#{HADOOP_TMP_DIR}#${HADOOP_TMP_DIR}#g" core-site.xml

# hdfs-site.xml
sed -i "s#{DFS_REPLICATION}#${DFS_REPLICATION}#g" hdfs-site.xml

# yarn-site.xml
sed -i "s#{RESOURCEMANAGER_HOSTNAME}#${RESOURCEMANAGER_HOSTNAME}#g" yarn-site.xml

# workers
if [ -n "${WORKERS}" ]; then
    ## split by ","
    echo "" > /etc/hadoop/conf/workers
    worker_arr=($(echo ${WORKERS} | tr "," "\n" | uniq))
    for current_worker in ${worker_arr[@]}
    do
        echo "${current_worker}" >> /etc/hadoop/conf/workers
    done
fi

# namenode format
if [[ ! -d "${HADOOP_TMP_DIR}/dfs/name" ]]; then
    echo 'Y' | {hdfs_module_home}/bin/hdfs namenode -format
fi
