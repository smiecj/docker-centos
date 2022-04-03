#!/bin/bash
#set -euxo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ./common.sh
. ./env_hdfs.sh

## install java
sh ./init-system-java.sh
source /etc/profile

## install hdfs
mkdir -p $hadoop_module_home
pushd $hadoop_module_home

rm -rf $hdfs_module_folder
curl -LO $hdfs_pkg_url
tar -xzvf $hdfs_pkg
rm -f $hdfs_pkg

pushd $hdfs_module_folder

### hdfs config

#### core-site.xml
cp -f $home_path/../components/hdfs/core-site.xml etc/hadoop/core-site.xml

#### hdfs-site.xml
cp -f $home_path/../components/hdfs/hdfs-site.xml etc/hadoop/hdfs-site.xml

#### mapred-site.xml
cp -f $home_path/../components/hdfs/mapred-site.xml etc/hadoop/mapred-site.xml

#### yarn-site.xml
cp -f $home_path/../components/hdfs/yarn-site.xml etc/hadoop/yarn-site.xml

#### link config path
mkdir -p /etc/hadoop
ln -s $hdfs_module_home/etc/hadoop /etc/hadoop/conf

### hdfs and yarn start and stop script env

#### start-dfs.sh
sed -i 's/## @description/\nHDFS_DATANODE_USER=root\nHDFS_NAMENODE_USER=root\nHDFS_SECONDARYNAMENODE_USER=root\n\n## @description/g' sbin/start-dfs.sh

#### stop-dfs.sh 
sed -i 's/## @description/\nHDFS_DATANODE_USER=root\nHDFS_NAMENODE_USER=root\nHDFS_SECONDARYNAMENODE_USER=root\n\n## @description/g' sbin/stop-dfs.sh

#### start-yarn.sh
sed -i 's/## @description/\nHDFS_DATANODE_USER=root\nHDFS_NAMENODE_USER=root\nHDFS_SECONDARYNAMENODE_USER=root\nYARN_RESOURCEMANAGER_USER=root\nYARN_NODEMANAGER_USER=root\n\n## @description/g' sbin/start-yarn.sh

#### stop-yarn.sh
sed -i 's/## @description/\nHDFS_DATANODE_USER=root\nHDFS_NAMENODE_USER=root\nHDFS_SECONDARYNAMENODE_USER=root\nYARN_RESOURCEMANAGER_USER=root\nYARN_NODEMANAGER_USER=root\n\n## @description/g' sbin/stop-yarn.sh

#### etc/hadoop/hadoop-env.sh (java home)
java_home_replace_str=$(echo "$JAVA_HOME" | sed 's/\//\\\//g')
sed -i 's/# export JAVA_HOME/export JAVA_HOME/g' etc/hadoop/hadoop-env.sh
sed -i "s/export JAVA_HOME.*/export JAVA_HOME=$java_home_replace_str/g" etc/hadoop/hadoop-env.sh

### namenode init
./bin/hdfs namenode -format

popd

popd

### env init
#### ssh
rm -rf ~/.ssh
mkdir -p ~/.ssh
ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa

cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 0600 ~/.ssh/authorized_keys

nohup ssh -o StrictHostKeyChecking=no localhost > /dev/null 2>&1 &
nohup ssh -o StrictHostKeyChecking=no 0.0.0.0 > /dev/null 2>&1 &

#### bash
chsh -s /bin/bash

### copy hdfs start script
mkdir -p $hdfs_scripts_home
cp -f $home_path/env_hdfs.sh $hdfs_scripts_home
cp -f $home_path/../components/hdfs/hdfs-restart.sh $hdfs_scripts_home
cp -f $home_path/../components/hdfs/hdfs-stop.sh $hdfs_scripts_home
chmod -R 744 $hdfs_scripts_home

### set hdfs profile (hive will use)
echo """
# hdfs
export HADOOP_HOME=$hdfs_module_home
export HADOOP_HDFS_HOME=\$HADOOP_HOME
export HADOOP_YARN_HOME=\$HADOOP_HOME
export HADOOP_MAPRED_HOME=\$HADOOP_HOME
""" >> /etc/profile

### add and enable hdfs service
add_systemd_service hdfs $PATH "" $hdfs_scripts_home/hdfs-restart.sh $hdfs_scripts_home/hdfs-stop.sh "true"

### add log rotate
mkdir -p $hadoop_log_home
add_logrorate_task $dfs_log_path dfs
add_logrorate_task $yarn_log_path yarn

popd
