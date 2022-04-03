hive_version=3.1.2

hive_pkg_url=https://mirrors.tuna.tsinghua.edu.cn/apache/hive/hive-$hive_version/apache-hive-$hive_version-bin.tar.gz
hive_pkg=`echo $hive_pkg_url | sed 's/.*\///g'`

hadoop_module_home=/home/modules/hadoop
hive_module_folder=apache-hive-$hive_version-bin

hive_module_home=$hadoop_module_home/$hive_module_folder
hive_scripts_home=$hive_module_home/scripts

hive_metastore_log_path=$hive_module_home/metastore.log
hive_hiveserver2_log_path=$hive_module_home/hiveserver2.log
