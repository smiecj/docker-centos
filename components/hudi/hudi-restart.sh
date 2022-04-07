#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ./env_hudi.sh

sh hudi-stop.sh

nohup $hudi_module_home/$spark_module/bin/spark-shell \
  --jars `ls $hudi_module_home/packaging/hudi-spark-bundle/target/hudi-spark-bundle_2.11-*.*.*-SNAPSHOT.jar` \
  --conf 'spark.serializer=org.apache.spark.serializer.KryoSerializer' > /dev/null 2>&1 &

popd