#!/bin/bash

# copy hdfs config folder
cp -r {hdfs_module_home}/etc/hadoop_default/* {hdfs_module_home}/etc/hadoop/

# core-site.xml
pushd {hdfs_module_home}/etc/hadoop/
sed -i "s#{DEFAULTFS}#${DEFAULTFS}#g" core-site.xml
sed -i "s#{HADOOP_TMP_DIR}#${HADOOP_TMP_DIR}#g" core-site.xml

## super user
if [[ -n "${SUPERUSER}" ]]; then
    user_list=($(echo ${SUPERUSER} | tr "," "\n" | uniq))
    for current_user in ${user_list[@]}
    do
        proxyuser_grep_out=`cat core-site.xml | grep hadoop.proxyuser.${current_user}.hosts`
        if [[ -z "${proxyuser_grep_out}" ]]; then
            sed -i "s#.*</configuration>.*##g" core-site.xml
            echo """
    <property>
        <name>hadoop.proxyuser.${current_user}.hosts</name>
        <value>*</value>
    </property>
    <property>
        <name>hadoop.proxyuser.${current_user}.groups</name>
        <value>*</value>
    </property>
  </configuration>
            """ >> core-site.xml
        fi
    done
fi

# hdfs-site.xml
sed -i "s#{DFS_REPLICATION}#${DFS_REPLICATION}#g" hdfs-site.xml

# yarn-site.xml
sed -i "s#{RESOURCEMANAGER_HOSTNAME}#${RESOURCEMANAGER_HOSTNAME}#g" yarn-site.xml
sed -i "s#{RESOURCEMANAGER_WEBAPP_ADDRESS}#${RESOURCEMANAGER_WEBAPP_ADDRESS}#g" yarn-site.xml

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

popd