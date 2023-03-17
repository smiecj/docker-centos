#!/bin/bash

jps -ml | grep "org.apache.zookeeper.server.quorum.QuorumPeerMain" | awk '{print $1}' | xargs --no-run-if-empty kill -9
sleep 3
