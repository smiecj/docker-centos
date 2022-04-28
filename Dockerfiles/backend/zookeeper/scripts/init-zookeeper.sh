#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path/conf

# init zookeeper config
## todo: support cluster zk config
zk_config_file=zoo.cfg
if [[ "singleton" == "${MODE}" ]]; then
    cp -f zoo_singleton.cfg $zk_config_file
fi
mkdir -p ${zookeeper_data_home}

zookeeper_data_home_replace_str=$(echo "$zookeeper_data_home" | sed 's/\//\\\//g')
sed -i "s/{data_dir}/$zookeeper_data_home_replace_str/g" $zk_config_file
sed -i "s/{port}/${PORT}/g" $zk_config_file

popd