#!/bin/bash
set -euxo pipefail

main_config=/etc/clickhouse-server/config.xml
main_config_template=/etc/clickhouse-server/config_template.xml
user_config=/etc/clickhouse-server/users.xml
user_config_template=/etc/clickhouse-server/users_template.xml

space_4="    "

## note: from https://github.com/smiecj/AmbariStack/blob/master/CLICKHOUSE/package/scripts/clickhouse.sh
set_zookeeper_nodes_config() {
    ### zookeeper config
    zookeeper_node_list_str="${ZOOKEEPER_NODES}"
    zk_address_list=($(echo $zookeeper_node_list_str | tr "," "\n" | sort | uniq))
    zk_replace_str="<zookeeper>"
    for zk_address in ${zk_address_list[@]}
    do
        IFS=':' read -r -a zk_split_list <<< $zk_address
        zk_host=${zk_split_list[0]}
        zk_port=${zk_split_list[1]}
        if [ -z $zk_port ]; then
            zk_port=$default_zk_port
        fi
        zk_replace_str="$zk_replace_str\n$space_4$space_4<node>"
        zk_replace_str="$zk_replace_str\n$space_4$space_4$space_4<host>$zk_host</host>"
        zk_replace_str="$zk_replace_str\n$space_4$space_4$space_4<port>$zk_port</port>"
        zk_replace_str="$zk_replace_str\n$space_4$space_4</node>"
    done
    zk_replace_str="$zk_replace_str\n$space_4</zookeeper>"

    sed -ie "s#<zookeeper>.*</zookeeper>#$zk_replace_str#g" $main_config
}

## replace replica nodes config
set_replica_nodes_config() {
    ### replica config
    #### get current node hostname and all to install hostname, to get current node number
    if [ -z "${REPLICA_NODES}" ]; then
        replica_node_list_str=`hostname`
    else
        replica_node_list_str=${REPLICA_NODES}
    fi
    local_host=`hostname`
    node_list=($(echo $replica_node_list_str | tr "," "\n" | sort | uniq))
    current_node_no=0
    for i in ${!node_list[@]};
    do
        if [ ${node_list[$i]} == $local_host ]; then
            current_node_no=$i
            break
        fi
    done
    current_node_no=$(printf "%02d" $current_node_no)

    #### default: shard count: same as node count; replica count: node count - 1
    node_tag="${CLUSTER_NAME}_${#node_list[@]}shards_2replicas"
    node_replace_str="<${node_tag}>"
    allow_internal_replication_str="<internal_replication>true</internal_replication>"
    for i in ${!node_list[@]};
    do
        #### add two replica node
        next_node=""
        if [[ $i -lt $((${#node_list[@]}-1)) ]]; then
            next_node=${node_list[$i+1]}
        else
            next_node=${node_list[0]}
        fi
        replica_node_arr=(${node_list[$i]} $next_node)

        node_num_str=$(printf "%02d" $i)
        database_num="${USER_DEFAULT_DB_PREFIX}$node_num_str"
        for replica_node in ${replica_node_arr[@]}
        do
            node_replace_str="$node_replace_str\n$space_4$space_4$space_4<shard>"
            node_replace_str="$node_replace_str\n$space_4$space_4$space_4$space_4$allow_internal_replication_str"
            node_replace_str="$node_replace_str\n$space_4$space_4$space_4$space_4<replica>"
            node_replace_str="$node_replace_str\n$space_4$space_4$space_4$space_4$space_4<default_database>$database_num</default_database>"
            node_replace_str="$node_replace_str\n$space_4$space_4$space_4$space_4$space_4<host>$replica_node</host>"
            node_replace_str="$node_replace_str\n$space_4$space_4$space_4$space_4$space_4<port>${HTTP_PORT}</port>"
            node_replace_str="$node_replace_str\n$space_4$space_4$space_4$space_4$space_4<user>${USER_NAME}</user>"
            node_replace_str="$node_replace_str\n$space_4$space_4$space_4$space_4$space_4<password>${USER_PASSWORD}</password>"
            node_replace_str="$node_replace_str\n$space_4$space_4$space_4$space_4</replica>"
            node_replace_str="$node_replace_str\n$space_4$space_4$space_4</shard>"
        done
    done
    node_replace_str="$node_replace_str\n$space_4$space_4</${node_tag}>"

    sed -ie "s#<cluster_nshards_2replicas>.*</cluster_nshards_2replicas>#$node_replace_str#g" $main_config

    sed -i "s#<shard>shard_no</shard>#<shard>$current_node_no</shard>#g" $main_config
    sed -i "s#<replica>replica_no</replica>#<replica>$current_node_no</replica>#g" $main_config
}

## set normal user allow database and set config file
set_normal_user_allow_databases() {
    normal_user_replace_str="<${USER_NAME}>"
    normal_user_replace_str="$normal_user_replace_str\n$space_4$space_4$space_4<password>${USER_PASSWORD}</password>"
    normal_user_replace_str="$normal_user_replace_str\n$space_4$space_4$space_4<profile>default</profile>"
    normal_user_replace_str="$normal_user_replace_str\n$space_4$space_4$space_4<quota>default</quota>"
    normal_user_replace_str="$normal_user_replace_str\n$space_4$space_4$space_4<networks>"
    normal_user_replace_str="$normal_user_replace_str\n$space_4$space_4$space_4$space_4<ip>::/0</ip>"
    normal_user_replace_str="$normal_user_replace_str\n$space_4$space_4$space_4</networks>"
    normal_user_replace_str="$normal_user_replace_str\n$space_4$space_4$space_4<allow_databases>"
    allow_database_list=($(echo ${USER_ALLOW_DB} | tr "," "\n" | sort | uniq))
    for allow_database in ${allow_database_list[@]}
    do
        normal_user_replace_str="$normal_user_replace_str\n$space_4$space_4$space_4$space_4<database>${allow_database}</database>"
    done
    normal_user_replace_str="$normal_user_replace_str\n$space_4$space_4$space_4</allow_databases>"
    normal_user_replace_str="$normal_user_replace_str\n$space_4$space_4</${USER_NAME}>"
    sed -ie "s#<normal_user></normal_user>#$normal_user_replace_str#g" ${user_config}
    sed -i "s#<max_memory_usage>10000000000</max_memory_usage>#<max_memory_usage>10000000000</max_memory_usage>\n$space_4$space_4$space_4<max_partitions_per_insert_block>1000</max_partitions_per_insert_block>#g" ${user_config}
}

main() {
    cp ${main_config_template} ${main_config}
    cp ${user_config_template} ${user_config}

    sed -i "s#{DATA_PATH}#${DATA_PATH}#g" ${main_config}
    sed -i "s#{TMP_PATH}#${TMP_PATH}#g" ${main_config}

    sed -i "s#{HTTP_PORT}#${HTTP_PORT}#g" ${main_config}
    sed -i "s#{TCP_PORT}#${TCP_PORT}#g" ${main_config}
    sed -i "s#{METRICS_PORT}#${METRICS_PORT}#g" ${main_config}

    set_zookeeper_nodes_config
    set_replica_nodes_config
    set_normal_user_allow_databases 

    sed -i 's/\r//' ${main_config}
    sed -i 's/\r//' ${user_config}
}

main