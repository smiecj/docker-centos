#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path/conf

# create zookeeper data dir if not exist
mkdir -p ${zookeeper_data_home}

# init zookeeper config
zk_config_file=zoo.cfg
if [[ "singleton" == "${MODE}" ]]; then
    cp -f zoo_singleton.cfg $zk_config_file
elif [[ "cluster" == "${MODE}" ]]; then
    cp -f zoo_cluster.cfg $zk_config_file
    ### split server info
    node_list=($(echo $SERVER_INFO | tr "," "\n"))
    index=1
    server_info=""
    for current_node in ${node_list[@]}
    do
        server_info="$server_info\nserver.$index=$current_node"
        index=$((index+1))
    done
    sed -i "s/{server_info}/${server_info}/g" $zk_config_file

    ### myid
    echo "${MYID}" > $zookeeper_data_home/myid
fi

zookeeper_data_home_replace_str=$(echo "$zookeeper_data_home" | sed 's/\//\\\//g')
sed -i "s/{data_dir}/$zookeeper_data_home_replace_str/g" $zk_config_file
sed -i "s/{port}/${PORT}/g" $zk_config_file

popd