FROM centos_java AS java_base

USER root
ENV HOME /root

# install hdfs
ARG hdfs_version=3.3.2

#hdfs_pkg_url=https://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/core/hadoop-$hdfs_version/hadoop-$hdfs_version.tar.gz
#ARG hdfs_download_url=https://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-${hdfs_version}/hadoop-${hdfs_version}.tar.gz
ARG hdfs_download_url=https://dlcdn.apache.org/hadoop/common/hadoop-${hdfs_version}/hadoop-${hdfs_version}.tar.gz
ARG hdfs_pkg=hadoop-${hdfs_version}.tar.gz

ARG hadoop_module_home=/home/modules/hadoop
ARG hdfs_module_folder=hadoop-${hdfs_version}

ARG hdfs_module_home=${hadoop_module_home}/${hdfs_module_folder}
ARG hdfs_scripts_home=${hdfs_module_home}/scripts

ARG hadoop_log_home=/var/log/hadoop
ARG dfs_log_path=${hadoop_log_home}/dfs.log
ARG yarn_log_path=${hadoop_log_home}/yarn.log
RUN mkdir -p ${hadoop_log_home}

## install sshd
RUN ssh-keygen -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N "" && \
    ssh-keygen -t ecdsa -b 256 -f /etc/ssh/ssh_host_ecdsa_key -N "" && \
    ssh-keygen -t ed25519 -b 256 -f /etc/ssh/ssh_host_ed25519_key -N ""

### sshd s6 script
ARG sshd_s6_home=/etc/services.d/sshd
RUN mkdir -p ${sshd_s6_home} && \
    echo '#!/bin/bash' > ${sshd_s6_home}/run && \
    . /etc/crypto-policies/back-ends/opensshserver.config && . /etc/sysconfig/sshd && \
    echo "/usr/sbin/sshd -D $OPTIONS $CRYPTO_POLICY" >> ${sshd_s6_home}/run

## download package
RUN mkdir -p ${hadoop_module_home}
RUN cd ${hadoop_module_home} && curl -LO ${hdfs_download_url} && tar -xzvf ${hdfs_pkg} && rm -f ${hdfs_pkg}

## hdfs config

### copy config file
COPY ./conf/* ${hdfs_module_home}/etc/hadoop/

### link config path
RUN mkdir -p /etc/hadoop
RUN ln -s ${hdfs_module_home}/etc/hadoop /etc/hadoop/conf

### hdfs and yarn start and stop script env

#### start-dfs.sh
RUN sed -i 's/## @description/\nHDFS_DATANODE_USER=root\nHDFS_NAMENODE_USER=root\nHDFS_SECONDARYNAMENODE_USER=root\n\n## @description/g' ${hdfs_module_home}/sbin/start-dfs.sh

#### stop-dfs.sh 
RUN sed -i 's/## @description/\nHDFS_DATANODE_USER=root\nHDFS_NAMENODE_USER=root\nHDFS_SECONDARYNAMENODE_USER=root\n\n## @description/g' ${hdfs_module_home}/sbin/stop-dfs.sh

#### start-yarn.sh
RUN sed -i 's/## @description/\nHDFS_DATANODE_USER=root\nHDFS_NAMENODE_USER=root\nHDFS_SECONDARYNAMENODE_USER=root\nYARN_RESOURCEMANAGER_USER=root\nYARN_NODEMANAGER_USER=root\n\n## @description/g' ${hdfs_module_home}/sbin/start-yarn.sh

#### stop-yarn.sh
RUN sed -i 's/## @description/\nHDFS_DATANODE_USER=root\nHDFS_NAMENODE_USER=root\nHDFS_SECONDARYNAMENODE_USER=root\nYARN_RESOURCEMANAGER_USER=root\nYARN_NODEMANAGER_USER=root\n\n## @description/g' ${hdfs_module_home}/sbin/stop-yarn.sh

#### etc/hadoop/hadoop-env.sh (java home)
RUN source /etc/profile && \
    sed -i 's@# export JAVA_HOME@export JAVA_HOME@g' ${hdfs_module_home}/etc/hadoop/hadoop-env.sh && \
    sed -i "s@export JAVA_HOME.*@export JAVA_HOME=$JAVA_HOME@g" ${hdfs_module_home}/etc/hadoop/hadoop-env.sh

## namenode init
RUN source /etc/profile && ${hdfs_module_home}/bin/hdfs namenode -format

## env init
### ssh
RUN rm -rf $HOME/.ssh
RUN mkdir -p $HOME/.ssh
RUN ssh-keygen -t rsa -N '' -f $HOME/.ssh/id_rsa

RUN cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys
RUN chmod 0600 $HOME/.ssh/authorized_keys

RUN nohup ssh -o StrictHostKeyChecking=no localhost > /dev/null 2>&1 &
RUN nohup ssh -o StrictHostKeyChecking=no 0.0.0.0 > /dev/null 2>&1 &

### bash
RUN chsh -s /bin/bash

### copy hdfs start and stop script
COPY ./scripts/hdfs-start.sh /usr/local/bin/hdfsstart
COPY ./scripts/hdfs-stop.sh /usr/local/bin/hdfsstop
COPY ./scripts/hdfs-restart.sh /usr/local/bin/hdfsrestart
RUN sed -i "s#{hdfs_module_home}#${hdfs_module_home}#g" /usr/local/bin/hdfsstart && \
    sed -i "s#{dfs_log_path}#${dfs_log_path}#g" /usr/local/bin/hdfsstart && \
    sed -i "s#{yarn_log_path}#${yarn_log_path}#g" /usr/local/bin/hdfsstart && \
    chmod +x /usr/local/bin/hdfsstart && chmod +x /usr/local/bin/hdfsstop && chmod +x /usr/local/bin/hdfsrestart

### set hdfs profile (hive will use)
RUN echo -e """\n\
# hdfs\n\
export HADOOP_HOME=$hdfs_module_home\n\
export HADOOP_HDFS_HOME=\$HADOOP_HOME\n\
export HADOOP_YARN_HOME=\$HADOOP_HOME\n\
export HADOOP_MAPRED_HOME=\$HADOOP_HOME\n\
""" >> /etc/profile

### add and enable hdfs service
#### hdfs depend sshd service started, so need execute background
RUN echo "nohup hdfsstart > /dev/null 2>&1 &" >> /init_service

### add log rotate
RUN addlogrotate ${dfs_log_path} hdfs-dfs
RUN addlogrotate ${yarn_log_path} hdfs-yarn
