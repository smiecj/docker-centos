ARG KNOX_IMAGE
ARG HIVE_IMAGE
ARG HDFS_IMAGE

FROM ${KNOX_IMAGE} AS knox

FROM ${HIVE_IMAGE} AS hive

FROM ${HDFS_IMAGE}

USER root
ENV HOME /root

ARG module_home=/opt/modules

# spark
ARG spark_short_version=3.2
ARG hadoop_version=3.2
ARG spark_repo=https://mirrors.tuna.tsinghua.edu.cn/apache/spark
# ARG spark_repo=https://archive.apache.org/dist/spark
ARG spark_module_home=${module_home}/spark

## install
RUN mkdir -p ${spark_module_home} && cd ${spark_module_home} && \
### get spark download url
    spark_version=`curl -L ${spark_repo} | grep spark-${spark_short_version} | sed 's#/</a>.*##g' | sed 's#.*-##g'` && \
    spark_pkg=spark-${spark_version}-bin-hadoop${hadoop_version}.tgz && \
    spark_folder=spark-${spark_version}-bin-hadoop${hadoop_version} && \
    spark_pkg_url=${spark_repo}/spark-${spark_version}/${spark_pkg} && \
    echo ${spark_pkg_url} && \
### download pkg
    curl -LO ${spark_pkg_url} && tar -xzvf ${spark_pkg} && rm -f ${spark_pkg} && \
    mv ${spark_folder}/* ./ && rm -rf ${spark_folder} && rm bin/*cmd

RUN echo -e """\n\
# spark\n\
export SPARK_HOME=${spark_module_home}\n\
export PATH=\$PATH:\$SPARK_HOME/bin\n\
""" >> /etc/profile

## submit task
# ./bin/spark-submit --master yarn --deploy-mode cluster --class org.apache.spark.examples.SparkPi /home/modules/spark-3.2.1-bin-hadoop3.2/examples/jars/spark-examples_2.12-3.2.1.jar 100
# ./bin/spark-submit --master yarn --deploy-mode cluster --class org.apache.spark.examples.JavaSparkPi /home/modules/spark-3.2.1-bin-hadoop3.2/examples/jars/spark-examples_2.12-3.2.1.jar 100

# flink
ARG flink_version=1.15.0
ARG flink_spark_version=2.12
ARG flink_pkg_url=https://mirrors.tuna.tsinghua.edu.cn/apache/flink/flink-${flink_version}/flink-${flink_version}-bin-scala_${flink_spark_version}.tgz
ARG flink_pkg=flink-${flink_version}-bin-scala_${flink_spark_version}.tgz
ARG flink_module_folder=flink-${flink_version}

## install
RUN cd ${module_home} && curl -LO ${flink_pkg_url} && tar -xzvf ${flink_pkg} && rm -f ${flink_pkg}
RUN echo -e """\n\
# flink\n\
export FLINK_HOME=${module_home}/${flink_module_folder}\n\
export HADOOP_CLASSPATH=\`hadoop classpath\`\n\
export PATH=\$PATH:\$FLINK_HOME/bin\n\
""" >> /etc/profile

## submit task
# ./bin/flink run -m yarn-cluster ./examples/batch/WordCount.jar

# knox

## copy module files
ARG knox_module_home=${module_home}/knox
ARG knox_scripts_home=${knox_module_home}/scripts
ENV KNOX_PORT 8443
ENV WEBHDFS_ADDRESS localhost:50070
ENV YARN_ADDRESS localhost:8088
ENV KNOX_START knoxnotstart

COPY --from=knox ${knox_module_home} ${knox_module_home}

## copy start scripts
COPY --from=knox /usr/local/bin/knox* /usr/local/bin/

## init
RUN echo "sh ${knox_scripts_home}/init-knox.sh && \${KNOX_START}" >> /init_service

# hive
ARG hadoop_module_home=/opt/modules/hadoop
ARG hive_version=3.1.2
ARG hive_module_folder=apache-hive-$hive_version-bin
ARG hive_module_home=${hadoop_module_home}/${hive_module_folder}
ARG hive_scripts_home=${hive_module_home}/scripts
ARG hive_metastore_log=${hive_module_home}/metastore.log
ARG hive_hiveserver2_log=${hive_module_home}/hiveserver2.log

ENV mysql_host=localhost
ENV mysql_port=3306
ENV mysql_db=hive
ENV mysql_user=hive
ENV mysql_pwd=hive
ENV HIVE_START=hivenotstart

## hive module
RUN mkdir -p ${hive_module_home}
COPY --from=hive ${hive_module_home} ${hive_module_home}

## profile
COPY --from=hive /etc/profile /tmp/profile_hive
RUN sed -n '/# hive/,$p' /tmp/profile_hive >> /etc/profile
RUN rm -f /tmp/profile_hive

## scripts
COPY --from=hive /usr/local/bin/hive* /usr/local/bin/
RUN echo "sh ${hive_scripts_home}/init-hive.sh && nohup \${HIVE_START} > /dev/null 2>&1 &" >> /init_service

## set hive conf folder soft link
RUN mkdir -p /etc/hive && ln -s ${hive_module_home}/conf /etc/hive/conf

## logrotate
RUN addlogrotate ${hive_metastore_log} metastore && \
    addlogrotate ${hive_hiveserver2_log} hiveserver2
