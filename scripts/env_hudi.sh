hudi_version="0.10.1"
hudi_source_code_url=https://github.com/apache/hudi/archive/refs/tags/release-$hudi_version.tar.gz
hudi_source_pkg=`echo $hudi_source_code_url | sed 's/.*\///g'`
hudi_module=hudi-release-$hudi_version

spark_version=2.4.4
hadoop_version=2.7
spark_pkg_url=https://archive.apache.org/dist/spark/spark-$spark_version/spark-$spark_version-bin-hadoop$hadoop_version.tgz
spark_pkg=`echo $spark_pkg_url | sed 's/.*\///g'`
spark_module=`echo $spark_pkg | sed 's/\.tgz//g'`

hudi_module_home=/home/modules/hudi
hudi_scripts_home=$hudi_module_home/scripts

hudi_log_path=$hudi_module_home/hudi.log