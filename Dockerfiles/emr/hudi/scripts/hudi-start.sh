#!/bin/bash

nohup {hudi_module_home}/{spark_module_folder}/bin/spark-shell \
  --jars `ls {hudi_module_home}/packaging/hudi-spark-bundle/target/hudi-spark-bundle_2.11-*.*.*-SNAPSHOT.jar` \
  --conf 'spark.serializer=org.apache.spark.serializer.KryoSerializer' > /dev/null 2>&1 &
