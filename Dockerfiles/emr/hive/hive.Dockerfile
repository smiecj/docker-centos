ARG IMAGE_HDFS
FROM ${IMAGE_HDFS}

ARG module_home
ARG apache_repo
ARG maven_repo
ARG hive_version

# install hive
ENV mysql_host=localhost
ENV mysql_port=3306
ENV mysql_db=hive
ENV mysql_user=hive
ENV mysql_pwd=hive

## hive config and script
COPY ./hive-site.xml /tmp
COPY ./scripts/init-hive.sh /tmp

## hive scripts
COPY ./scripts/hive-restart.sh /usr/local/bin/hiverestart
COPY ./scripts/hive-start.sh /usr/local/bin/hivestart
COPY ./scripts/hive-stop.sh /usr/local/bin/hivestop
COPY ./scripts/hive-not-start.sh /usr/local/bin/hivenotstart
COPY ./scripts/hive-server-log.sh /usr/local/bin/hiveserverlog
COPY ./scripts/hive-metastore-log.sh /usr/local/bin/hivemetastorelog

RUN mysql_version=8.0.26 && \
    mysql_jdbc_url=${maven_repo}/mysql/mysql-connector-java/${mysql_version}/mysql-connector-java-${mysql_version}.jar && \
    hadoop_module_home=${module_home}/hadoop && \
    hive_module_home=${hadoop_module_home}/hive && \
    hive_scripts_home=${hive_module_home}/scripts && \

    hdfs_module_folder=`ls -l ${hadoop_module_home} | grep hadoop | sed "s#.* ##g"` && \
    hdfs_module_home=${hadoop_module_home}/${hdfs_module_folder} && \
    hive_metastore_log=${hive_module_home}/metastore.log && \
    hive_hiveserver2_log=${hive_module_home}/hiveserver2.log && \

## download package
    hive_repo=${apache_repo}/hive && \
    hive_pkg=apache-hive-${hive_version}-bin.tar.gz && \
    hive_pkg_url=${hive_repo}/hive-${hive_version}/${hive_pkg} && \
    hive_module_folder=apache-hive-${hive_version}-bin && \
    
    cd ${hadoop_module_home} && curl -LO ${hive_pkg_url} && tar -xzvf ${hive_pkg} && rm -f ${hive_pkg} && \
    mkdir -p ${hive_module_home} && mv ${hive_module_folder}/* ${hive_module_home} && \

    ## set hive conf folder soft link
    mkdir -p /etc/hive && ln -s ${hive_module_home}/conf /etc/hive/conf && \
    mkdir -p ${hive_scripts_home} && \
    mv /tmp/hive-site.xml /etc/hive/conf/hive-site-example.xml && \
    mv /tmp/init-hive.sh ${hive_scripts_home} && \

### hive-env
    cd ${hive_module_home}/conf && cp hive-env.sh.template hive-env.sh && \
    source /etc/profile && \
    sed -i "s@# HADOOP_HOME.*@export HADOOP_HOME=${hdfs_module_home}@g" hive-env.sh && \
    sed -i "s@# export HIVE_CONF_DIR.*@export HIVE_CONF_DIR=${hive_module_home}/conf@g" hive-env.sh && \
    
### jdbc jar
    cd ${hive_module_home}/lib && curl -LO ${mysql_jdbc_url} && \

### profile: hive bin
    echo "# hive" >> /etc/profile && \
    echo "export HIVE_HOME=${hive_module_home}" >> /etc/profile && \
    echo "export PATH=\$PATH:\$HIVE_HOME/bin" >> /etc/profile && \

    chmod +x /usr/local/bin/hiverestart && chmod +x /usr/local/bin/hivestart && chmod +x /usr/local/bin/hivestop && \
    sed -i "s#{hive_module_home}#${hive_module_home}#g" /usr/local/bin/hivestart && \
    sed -i "s#{hive_metastore_log}#${hive_metastore_log}#g" /usr/local/bin/hivestart && \
    sed -i "s#{hive_hiveserver2_log}#${hive_hiveserver2_log}#g" /usr/local/bin/hivestart && \
    sed -i "s#{hive_module_home}#${hive_module_home}#g" /usr/local/bin/hivestop && \
    sed -i "s#{hive_module_home}#${hive_module_home}#g" /usr/local/bin/hiveserverlog && \
    sed -i "s#{hive_module_home}#${hive_module_home}#g" /usr/local/bin/hivemetastorelog && \

## init service
    sed -i "s#{hive_module_home}#${hive_module_home}#g" ${hive_scripts_home}/init-hive.sh && \
    echo "sh ${hive_scripts_home}/init-hive.sh && nohup hivestart > /dev/null 2>&1 &" >> /init_service && \

## log rotate
    addlogrotate ${hive_metastore_log} metastore && \
    addlogrotate ${hive_hiveserver2_log} hiveserver2