druid_tag="0.22.1"
druid_pkg_download_url=https://github.com/apache/druid/archive/refs/tags/druid-$druid_tag.tar.gz
druid_pkg_name=`echo $druid_pkg_download_url | sed 's/.*\///g'`
druid_bin_pkg_download_url=https://dlcdn.apache.org/druid/$druid_tag/apache-druid-$druid_tag-bin.tar.gz
druid_folder_path="druid-druid-$druid_tag"
druid_bin_pkg_name="apache-druid-$druid_tag-bin.tar.gz"
druid_bin_path="apache-druid-$druid_tag"
druid_module_home=/home/modules/druid