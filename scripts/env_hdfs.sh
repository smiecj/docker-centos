hdfs_version=3.3.2

#hdfs_pkg_url=https://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/core/hadoop-$hdfs_version/hadoop-$hdfs_version.tar.gz
hdfs_pkg_url=https://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-$hdfs_version/hadoop-$hdfs_version.tar.gz
hdfs_pkg=`echo $hdfs_pkg_url | sed 's/.*\///g'`

hadoop_module_home=/home/modules/hadoop
hdfs_module_folder=hadoop-$hdfs_version

hdfs_module_home=$hadoop_module_home/$hdfs_module_folder
hdfs_scripts_home=$hdfs_module_home/scripts

hadoop_log_home=/var/log/hadoop
dfs_log_path=$hadoop_log_home/dfs.log
yarn_log_path=$hadoop_log_home/yarn.log
