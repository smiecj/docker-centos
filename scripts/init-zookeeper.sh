#!/bin/bash
set -euxo pipefail

DEPLOY_MODE_SINGLETON="singleton"
DEPLOY_MODE_CLUSTER="cluster"

# zk config init
deploy_mode="singleton"
if [ "" != "$DEPLOY_MODE" ]; then
    deploy_mode=$DEPLOY_MODE
fi

if [ $deploy_mode == $DEPLOY_MODE_SINGLETON ]; then
    echo "singleton deploy mode"
    cp -f /home/modules/zookeeper/conf/zoo_singleton.cfg /home/modules/zookeeper/conf/zoo.cfg
else
    ## todo: support more than 3 nodes 
    echo "cluster deploy mode"
    sed -i "s/{zoo_node_1}/$ZK_NODE_1/g" $ZK_NODE_1
    sed -i "s/{zoo_node_2}/$ZK_NODE_2/g" $ZK_NODE_2
    sed -i "s/{zoo_node_3}/$ZK_NODE_3/g" $ZK_NODE_3
    cp -f /home/modules/zookeeper/conf/zoo_cluster.cfg /home/modules/zookeeper/conf/zoo.cfg
fi

exec /usr/sbin/init

service zookeeper restart
