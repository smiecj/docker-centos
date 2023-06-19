ARG IMAGE_HDFS_BASE
FROM ${IMAGE_HDFS_BASE}

ARG apache_repo
ARG module_home

ENV HDFS_START hdfsstart
ENV DEFAULTFS hdfs://localhost:8020
ENV HADOOP_TMP_DIR /opt/data/hdfs/tmp
ENV DFS_REPLICATION 1
ENV RESOURCEMANAGER_HOSTNAME localhost
ENV RESOURCEMANAGER_WEBAPP_ADDRESS 0.0.0.0:8088
ENV WORKERS localhost
ENV SUPERUSER=admin,root
ENV INIT_SERVICE="ssh"

# install hdfs
ARG hdfs_version

# copy scripts and config
COPY ./conf/ /tmp/conf/
COPY ./scripts/init-hdfs.sh /tmp
COPY ./scripts/hdfs-start.sh /usr/local/bin/hdfsstart
COPY ./scripts/hdfs-stop.sh /usr/local/bin/hdfsstop
COPY ./scripts/hdfs-restart.sh /usr/local/bin/hdfsrestart
COPY ./scripts/hdfs-restart-all.sh /usr/local/bin/hdfsrestartall
COPY ./scripts/hdfs-start-all.sh /usr/local/bin/hdfsstartall
COPY ./scripts/hdfs-stop-all.sh /usr/local/bin/hdfsstopall
COPY ./scripts/hdfs-not-start.sh /usr/local/bin/hdfsnotstart

RUN hadoop_module_home=${module_home}/hadoop && \
    hdfs_module_folder=hadoop-${hdfs_version} && \
    hdfs_module_home=${hadoop_module_home}/${hdfs_module_folder} && \
    hdfs_scripts_home=${hdfs_module_home}/scripts && \

    hadoop_log_home=/var/log/hadoop && \
    dfs_log_path=${hadoop_log_home}/dfs.log && \
    yarn_log_path=${hadoop_log_home}/yarn.log && \

    mkdir -p ${hadoop_log_home} && \

## download package
    hdfs_repo=${apache_repo}/hadoop/common && \
    hdfs_pkg=hadoop-${hdfs_version}.tar.gz && \
    hdfs_download_url=${hdfs_repo}/hadoop-${hdfs_version}/${hdfs_pkg} && \
    mkdir -p ${hadoop_module_home} && \
    cd ${hadoop_module_home} && curl -LO ${hdfs_download_url} && tar -xzvf ${hdfs_pkg} && rm ${hdfs_pkg} && \

### copy config file
mkdir -p ${hdfs_scripts_home} && \
mv /tmp/init-hdfs.sh ${hdfs_scripts_home} && \
mv /tmp/conf/* ${hdfs_module_home}/etc/hadoop/ && \
rm -rf /tmp/conf && \

#### init script
sed -i "s#{hdfs_module_home}#${hdfs_module_home}#g" ${hdfs_scripts_home}/init-hdfs.sh && \

### link config path
mkdir -p /etc/hadoop && \
ln -s ${hdfs_module_home}/etc/hadoop /etc/hadoop/conf && \
#### copy default config for volume
cp -r ${hdfs_module_home}/etc/hadoop ${hdfs_module_home}/etc/hadoop_default && \

### hdfs and yarn start and stop script env

#### start-dfs.sh
sed -i 's/## @description/\nHDFS_DATANODE_USER=root\nHDFS_NAMENODE_USER=root\nHDFS_SECONDARYNAMENODE_USER=root\n\n## @description/g' ${hdfs_module_home}/sbin/start-dfs.sh && \

#### stop-dfs.sh 
sed -i 's/## @description/\nHDFS_DATANODE_USER=root\nHDFS_NAMENODE_USER=root\nHDFS_SECONDARYNAMENODE_USER=root\n\n## @description/g' ${hdfs_module_home}/sbin/stop-dfs.sh && \

#### start-yarn.sh
sed -i 's/## @description/\nHDFS_DATANODE_USER=root\nHDFS_NAMENODE_USER=root\nHDFS_SECONDARYNAMENODE_USER=root\nYARN_RESOURCEMANAGER_USER=root\nYARN_NODEMANAGER_USER=root\n\n## @description/g' ${hdfs_module_home}/sbin/start-yarn.sh && \

#### stop-yarn.sh
sed -i 's/## @description/\nHDFS_DATANODE_USER=root\nHDFS_NAMENODE_USER=root\nHDFS_SECONDARYNAMENODE_USER=root\nYARN_RESOURCEMANAGER_USER=root\nYARN_NODEMANAGER_USER=root\n\n## @description/g' ${hdfs_module_home}/sbin/stop-yarn.sh && \

#### etc/hadoop/hadoop-env.sh (java home)
source /etc/profile && \
sed -i 's@# export JAVA_HOME@export JAVA_HOME@g' ${hdfs_module_home}/etc/hadoop/hadoop-env.sh && \
sed -i "s@export JAVA_HOME.*@export JAVA_HOME=$JAVA_HOME@g" ${hdfs_module_home}/etc/hadoop/hadoop-env.sh && \

## namenode init
#RUN source /etc/profile && echo 'Y' | ${hdfs_module_home}/bin/hdfs namenode -format

## env init
### ssh
rm -rf $HOME/.ssh && \
mkdir -p $HOME/.ssh && \
ssh-keygen -t rsa -N '' -f $HOME/.ssh/id_rsa && \

cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys && \
chmod 0600 $HOME/.ssh/authorized_keys && \

### bash
chsh -s /bin/bash && \

### copy hdfs start and stop script
sed -i "s#{hdfs_module_home}#${hdfs_module_home}#g" /usr/local/bin/hdfsstart && \
sed -i "s#{dfs_log_path}#${dfs_log_path}#g" /usr/local/bin/hdfsstart && \
sed -i "s#{yarn_log_path}#${yarn_log_path}#g" /usr/local/bin/hdfsstart && \
sed -i "s#{hdfs_module_home}#${hdfs_module_home}#g" /usr/local/bin/hdfsstartall && \
sed -i "s#{hdfs_module_home}#${hdfs_module_home}#g" /usr/local/bin/hdfsstopall && \
chmod +x /usr/local/bin/* && \

### set hdfs profile (hive will use)
echo "# hdfs" >> /etc/profile && \
echo -e """export HADOOP_HOME=$hdfs_module_home\n\
export HADOOP_HDFS_HOME=\$HADOOP_HOME\n\
export HADOOP_YARN_HOME=\$HADOOP_HOME\n\
export HADOOP_MAPRED_HOME=\$HADOOP_HOME\n\
export HADOOP_CONF_DIR=\$HADOOP_HOME/etc/hadoop\n\
export PATH=\$PATH:\$HADOOP_HOME/bin\n\
""" >> /etc/profile && \

### add and enable hdfs service
#### hdfs depend sshd service started, so need execute background

echo "source /etc/profile && sh ${hdfs_scripts_home}/init-hdfs.sh && nohup \${HDFS_START} > /dev/null 2>&1 &" >> /init_service && \

### add log rotate
addlogrotate ${dfs_log_path} hdfs-dfs && \
addlogrotate ${yarn_log_path} hdfs-yarn