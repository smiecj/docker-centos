#!/bin/bash

# jps -ml | grep "org.apache.hadoop.hbase.master.HMaster" | awk '{print $1}' | xargs --no-run-if-empty kill -9

{hbase_module_home}/bin/stop-hbase.sh