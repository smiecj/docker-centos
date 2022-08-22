ARG HDFS_IMAGE
FROM ${HDFS_IMAGE}

# install hive
ARG mysql_version=8.0.26
ENV mysql_host=localhost
ENV mysql_port=3306
ENV mysql_db=hive
ENV mysql_user=hive
ENV mysql_pwd=hive

ARG hadoop_module_home=/opt/modules/hadoop

ARG hive_version=3.1.2
ARG hive_repo=https://mirrors.tuna.tsinghua.edu.cn/apache/hive
ARG hive_pkg_url=${hive_repo}/hive-${hive_version}/apache-hive-${hive_version}-bin.tar.gz
ARG hive_pkg=apache-hive-${hive_version}-bin.tar.gz
ARG hive_module_folder=apache-hive-$hive_version-bin

ARG hive_module_home=${hadoop_module_home}/${hive_module_folder}
ARG hive_scripts_home=${hive_module_home}/scripts

ARG hdfs_version=3.3.2
ARG hdfs_module_folder=hadoop-${hdfs_version}
ARG hdfs_module_home=${hadoop_module_home}/${hdfs_module_folder}

ARG hive_metastore_log=${hive_module_home}/metastore.log
ARG hive_hiveserver2_log=${hive_module_home}/hiveserver2.log

ARG mysql_jdbc_url=https://repo1.maven.org/maven2/mysql/mysql-connector-java/${mysql_version}/mysql-connector-java-${mysql_version}.jar

## download package
RUN cd ${hadoop_module_home} && curl -LO $hive_pkg_url && tar -xzvf $hive_pkg && rm -f $hive_pkg

## hive config
COPY ./hive-site.xml ${hive_module_home}/conf/hive-site-example.xml

### hive-env
RUN cd ${hive_module_home}/conf && cp hive-env.sh.template hive-env.sh && \
    sed -i "s@# HADOOP_HOME.*@export HADOOP_HOME=$hdfs_module_home@g" hive-env.sh && \
    sed -i "s@# HIVE_CONF_DIR.*@export HIVE_CONF_DIR=$hive_module_home@g" hive-env.sh

### jdbc jar
RUN cd ${hive_module_home}/lib && curl -LO ${mysql_jdbc_url}

## set hive conf folder soft link
RUN mkdir -p /etc/hive && ln -s ${hive_module_home}/conf /etc/hive/conf

## profile: hive bin
RUN echo "# hive" >> /etc/profile && \
    echo "export HIVE_HOME=${hive_module_home}" >> /etc/profile && \
    echo "export PATH=\$PATH:\$HIVE_HOME/bin" >> /etc/profile

## hive scripts
COPY ./scripts/hive-restart.sh /usr/local/bin/hiverestart
COPY ./scripts/hive-start.sh /usr/local/bin/hivestart
COPY ./scripts/hive-stop.sh /usr/local/bin/hivestop
COPY ./scripts/hive-not-start.sh /usr/local/bin/hivenotstart
RUN chmod +x /usr/local/bin/hiverestart && chmod +x /usr/local/bin/hivestart && chmod +x /usr/local/bin/hivestop
RUN sed -i "s#{hive_module_home}#${hive_module_home}#g" /usr/local/bin/hivestart && \
    sed -i "s#{hive_metastore_log}#${hive_metastore_log}#g" /usr/local/bin/hivestart && \
    sed -i "s#{hive_hiveserver2_log}#${hive_hiveserver2_log}#g" /usr/local/bin/hivestart && \
    sed -i "s#{hive_module_home}#${hive_module_home}#g" /usr/local/bin/hivestop

## init service
RUN mkdir -p ${hive_scripts_home}
COPY ./scripts/init-hive.sh ${hive_scripts_home}/
RUN sed -i "s#{hive_module_home}#${hive_module_home}#g" ${hive_scripts_home}/init-hive.sh
RUN echo "sh ${hive_scripts_home}/init-hive.sh && nohup hivestart > /dev/null 2>&1 &" >> /init_service

## log rotate
RUN addlogrotate ${hive_metastore_log} metastore && \
    addlogrotate ${hive_hiveserver2_log} hiveserver2