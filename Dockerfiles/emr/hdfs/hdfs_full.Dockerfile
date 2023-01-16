ARG IMAGE_KNOX
ARG IMAGE_HIVE
ARG IMAGE_HDFS

FROM ${IMAGE_KNOX} AS knox

FROM ${IMAGE_HIVE} AS hive

FROM ${IMAGE_HDFS}

ARG module_home
ARG apache_repo

ARG spark_short_version
ARG spark_hadoop_version

ARG flink_short_version
ARG flink_spark_version

ARG hive_version

## env
ENV KNOX_PORT 8443
ENV WEBHDFS_ADDRESS localhost:50070
ENV YARN_ADDRESS localhost:8088
ENV KNOX_START knoxnotstart

ENV mysql_host=localhost
ENV mysql_port=3306
ENV mysql_db=hive
ENV mysql_user=hive
ENV mysql_pwd=hive
ENV HIVE_START=hivenotstart

## copy
COPY --from=knox ${module_home}/knox /tmp/knox
COPY --from=knox /usr/local/bin/knox* /usr/local/bin/
COPY --from=hive ${module_home}/hadoop/hive /tmp/hive
COPY --from=hive /etc/profile /tmp/profile_hive
COPY --from=hive /usr/local/bin/hive* /usr/local/bin/

## install spark
RUN spark_module_home=${module_home}/spark && \
    spark_repo=${apache_repo}/spark && \
    mkdir -p ${spark_module_home} && cd ${spark_module_home} && \
### get spark download url
    spark_version=`curl -L ${spark_repo}/ | grep spark-${spark_short_version} | sed 's#/</a>.*##g' | sed 's#.*-##g' | tail -1` && \
    spark_pkg=spark-${spark_version}-bin-hadoop${spark_hadoop_version}.tgz && \
    spark_folder=spark-${spark_version}-bin-hadoop${spark_hadoop_version} && \
    spark_pkg_url=${spark_repo}/spark-${spark_version}/${spark_pkg} && \
    echo ${spark_pkg_url} && \
### download pkg
    curl -LO ${spark_pkg_url} && tar -xzvf ${spark_pkg} && rm -f ${spark_pkg} && \
    mv ${spark_folder}/* ./ && rm -rf ${spark_folder} && rm bin/*cmd

RUN echo -e """\n\
# spark\n\
export SPARK_HOME=${spark_module_home}\n\
export PATH=\$PATH:\$SPARK_HOME/bin\n\
""" >> /etc/profile && \

## submit task
# ./bin/spark-submit --master yarn --deploy-mode cluster --class org.apache.spark.examples.SparkPi /home/modules/spark-3.2.1-bin-hadoop3.2/examples/jars/spark-examples_2.12-3.2.1.jar 100
# ./bin/spark-submit --master yarn --deploy-mode cluster --class org.apache.spark.examples.JavaSparkPi /home/modules/spark-3.2.1-bin-hadoop3.2/examples/jars/spark-examples_2.12-3.2.1.jar 100

# install flink
    flink_repo=${apache_repo}/flink && \
    flink_version=`curl -L ${flink_repo}/ | grep "flink-${flink_short_version}" | sed 's#/<.*##g' | sed 's#.*>##g' | sed 's/flink-//g' | tail -1` && \
    flink_pkg_url=${flink_repo}/flink-${flink_version}/flink-${flink_version}-bin-scala_${flink_spark_version}.tgz && \
    flink_pkg=flink-${flink_version}-bin-scala_${flink_spark_version}.tgz && \
    flink_module_folder=flink-${flink_version} && \
    cd ${module_home} && curl -LO ${flink_pkg_url} && tar -xzvf ${flink_pkg} && rm -f ${flink_pkg} && \
    echo -e """\n\
# flink\n\
export FLINK_HOME=${module_home}/${flink_module_folder}\n\
export HADOOP_CLASSPATH=\`hadoop classpath\`\n\
export PATH=\$PATH:\$FLINK_HOME/bin\n\
""" >> /etc/profile && \

## submit task
# ./bin/flink run -m yarn-cluster ./examples/batch/WordCount.jar

# knox

## knox
knox_module_home=${module_home}/knox && \
knox_scripts_home=${knox_module_home}/scripts && \
mkdir -p ${knox_module_home} && \
mv /tmp/knox/*  ${knox_module_home}/ && \
rm -rf /tmp/knox && \
echo "sh ${knox_scripts_home}/init-knox.sh && \${KNOX_START}" >> /init_service && \

# hive
hadoop_module_home=${module_home}/hadoop && \
hive_module_home=${hadoop_module_home}/hive && \
hive_scripts_home=${hive_module_home}/scripts && \
hive_metastore_log=${hive_module_home}/metastore.log && \
hive_hiveserver2_log=${hive_module_home}/hiveserver2.log && \

## hive module
mkdir -p ${hive_module_home} && \
mv /tmp/hive/* ${hive_module_home}/ && \
rm -rf /tmp/hive && \

## profile
sed -n '/# hive/,$p' /tmp/profile_hive >> /etc/profile && \
rm /tmp/profile_hive && \

## scripts
echo "sh ${hive_scripts_home}/init-hive.sh && nohup \${HIVE_START} > /dev/null 2>&1 &" >> /init_service && \

## set hive conf folder soft link
mkdir -p /etc/hive && ln -s ${hive_module_home}/conf /etc/hive/conf && \

## logrotate
addlogrotate ${hive_metastore_log} metastore && \
addlogrotate ${hive_hiveserver2_log} hiveserver2
