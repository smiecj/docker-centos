#!/bin/bash

nohup {hive_module_home}/bin/hive --service metastore > {hive_metastore_log} 2>&1 &

nohup {hive_module_home}/bin/hive --service hiveserver2 --hiveconf hive.root.logger=INFO,console > {hive_hiveserver2_log} 2>&1 &