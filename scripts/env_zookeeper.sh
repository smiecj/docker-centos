zookeeper_tag="release-3.6.3"
zookeeper_version_num=`echo $zookeeper_tag | sed 's/.*-//g'`

zookeeper_source_url=https://github.com/apache/zookeeper/archive/refs/tags/$zookeeper_tag.tar.gz
zookeeper_source_pkg=`echo $zookeeper_source_url | sed 's/.*\///g'`
zookeeper_source_folder=zookeeper-$zookeeper_tags
zookeeper_pkg=apache-zookeeper-$zookeeper_version_num-bin.tar.gz
zookeeper_folder=$zookeeper_version_num-bin

zookeeper_module_home=/home/modules/zookeeper