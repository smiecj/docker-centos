zookeeper_tag="release-3.6.3"
zookeeper_version_num=`echo $zookeeper_tag | sed 's/.*-//g'`

zookeeper_source_url=https://github.com/apache/zookeeper/archive/refs/tags/$zookeeper_tag.tar.gz
zookeeper_source_pkg=`echo $zookeeper_source_url | sed 's/.*\///g'`
zookeeper_source_folder=zookeeper-$zookeeper_tag
zookeeper_pkg=apache-zookeeper-$zookeeper_version_num-bin.tar.gz
zookeeper_folder=apache-zookeeper-$zookeeper_version_num-bin

zookeeper_module_home=/home/modules/zookeeper
zookeeper_pkg_home=$zookeeper_module_home/$zookeeper_folder
zookeeper_data_home=$zookeeper_module_home/data
zookeeper_scripts_home=$zookeeper_module_home/scripts
zookeeper_log_path=$zookeeper_module_home/zk_server.log