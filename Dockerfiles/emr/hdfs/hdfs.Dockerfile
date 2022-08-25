ARG PYTHON_IMAGE
ARG JAVA_IMAGE

FROM ${PYTHON_IMAGE} AS base_python
FROM ${JAVA_IMAGE}

USER root
ENV HOME /root

# python

## copy python (conda) package
ARG miniconda_install_path=/usr/local/miniconda
ARG conda_env_name_python3=py3
COPY --from=base_python ${miniconda_install_path} ${miniconda_install_path}

## python soft link (copy)
ARG python3_home_path=${miniconda_install_path}/envs/${conda_env_name_python3}
RUN rm -f /usr/bin/python* && rm -f /usr/bin/pip* && \
    ln -s ${python3_home_path}/bin/python3 /usr/bin/python3 && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    ln -s $python3_home_path/bin/pip3 /usr/bin/pip3 && \
    ln -s /usr/bin/pip3 /usr/bin/pip

## pip repo
RUN mkdir -p /root/.pip
COPY --from=base_python /root/.pip/pip.conf /root/.pip/

## python profile
COPY --from=base_python /etc/profile /tmp/profile_python
RUN sed -n '/# conda/,$p' /tmp/profile_python >> /etc/profile
RUN rm /tmp/profile_python

# install hdfs
ARG hdfs_version=3.3.2

ARG hdfs_repo=https://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common
# ARG hdfs_repo=https://dlcdn.apache.org/hadoop/common
ARG hdfs_pkg=hadoop-${hdfs_version}.tar.gz
ARG hdfs_download_url=${hdfs_repo}/hadoop-${hdfs_version}/${hdfs_pkg}

ARG hadoop_module_home=/opt/modules/hadoop
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

#### ENV
ENV DEFAULTFS hdfs://localhost:8020
ENV HADOOP_TMP_DIR /opt/data/hdfs/tmp
ENV DFS_REPLICATION 1
ENV RESOURCEMANAGER_HOSTNAME localhost
ENV RESOURCEMANAGER_WEBAPP_ADDRESS 0.0.0.0:8088
ENV WORKERS localhost

#### init script
RUN mkdir -p ${hdfs_scripts_home}
COPY ./scripts/init-hdfs.sh ${hdfs_scripts_home}
RUN sed -i "s#{hdfs_module_home}#${hdfs_module_home}#g" ${hdfs_scripts_home}/init-hdfs.sh

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
#RUN source /etc/profile && echo 'Y' | ${hdfs_module_home}/bin/hdfs namenode -format

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
COPY ./scripts/hdfs-restart-all.sh /usr/local/bin/hdfsrestartall
COPY ./scripts/hdfs-start-all.sh /usr/local/bin/hdfsstartall
COPY ./scripts/hdfs-stop-all.sh /usr/local/bin/hdfsstopall
COPY ./scripts/hdfs-not-start.sh /usr/local/bin/hdfsnotstart
RUN sed -i "s#{hdfs_module_home}#${hdfs_module_home}#g" /usr/local/bin/hdfsstart && \
    sed -i "s#{dfs_log_path}#${dfs_log_path}#g" /usr/local/bin/hdfsstart && \
    sed -i "s#{yarn_log_path}#${yarn_log_path}#g" /usr/local/bin/hdfsstart && \
    sed -i "s#{hdfs_module_home}#${hdfs_module_home}#g" /usr/local/bin/hdfsstartall && \
    sed -i "s#{hdfs_module_home}#${hdfs_module_home}#g" /usr/local/bin/hdfsstopall && \
    chmod +x /usr/local/bin/*

### set hdfs profile (hive will use)
RUN echo "# hdfs" >> /etc/profile
RUN echo -e """export HADOOP_HOME=$hdfs_module_home\n\
export HADOOP_HDFS_HOME=\$HADOOP_HOME\n\
export HADOOP_YARN_HOME=\$HADOOP_HOME\n\
export HADOOP_MAPRED_HOME=\$HADOOP_HOME\n\
export HADOOP_CONF_DIR=\$HADOOP_HOME/etc/hadoop\n\
export PATH=\$PATH:\$HADOOP_HOME/bin\n\
""" >> /etc/profile

### add and enable hdfs service
#### hdfs depend sshd service started, so need execute background
ENV HDFS_START hdfsstart
RUN echo "source /etc/profile && sh ${hdfs_scripts_home}/init-hdfs.sh && nohup \${HDFS_START} > /dev/null 2>&1 &" >> /init_service

### add log rotate
RUN addlogrotate ${dfs_log_path} hdfs-dfs
RUN addlogrotate ${yarn_log_path} hdfs-yarn
