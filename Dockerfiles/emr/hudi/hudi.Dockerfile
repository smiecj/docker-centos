ARG IMAGE_JAVA
FROM ${IMAGE_JAVA}

# install hudi
ARG module_home
ARG apache_repo
ARG hudi_version

# scripts
COPY ./scripts/hudi-restart.sh /usr/local/bin/hudirestart
COPY ./scripts/hudi-start.sh /usr/local/bin/hudistart
COPY ./scripts/hudi-stop.sh /usr/local/bin/hudistop

## download source code
RUN hudi_module_home=${module_home}/hudi && \
    spark_version=2.4.8 && \
    hadoop_version=2.7 && \
    spark_pkg_url=${apache_repo}/spark/spark-${spark_version}/spark-${spark_version}-bin-hadoop${hadoop_version}.tgz && \
    spark_pkg=spark-${spark_version}-bin-hadoop${hadoop_version}.tgz && \
    spark_module_folder=spark-${spark_version}-bin-hadoop${hadoop_version} && \
    hudi_repo=${apache_repo}/hudi && \
    hudi_source_pkg=hudi-${hudi_version}.src.tgz && \
    hudi_source_code_url=${hudi_repo}/${hudi_version}/${hudi_source_pkg} && \
    hudi_source_folder=hudi-${hudi_version} && \
    hudi_source_home=${hudi_module_home}/${hudi_source_folder} && \

    mkdir -p ${hudi_module_home} && \
    cd ${hudi_module_home} && curl -LO ${hudi_source_code_url} && \
    tar -xzvf ${hudi_source_pkg} && rm ${hudi_source_pkg} && \

## compile
    cd ${hudi_source_home} && source /etc/profile && mvn clean package -DskipTests && \
    cd ${hudi_source_home} && mv packaging/* ${hudi_module_home} && rm -rf ${hudi_source_home} && \
    rm -rf ~/.m2/repository/* && \

## spark download
    cd ${hudi_module_home} && curl -LO ${spark_pkg_url} && \
    tar -xvf ${spark_pkg} && rm ${spark_pkg} && \

## add and enable hudi service
    sed -i "s#{hudi_module_home}#$hudi_module_home#g" /usr/local/bin/hudistart && \
    sed -i "s#{spark_module_folder}#$spark_module_folder#g" /usr/local/bin/hudistart && \
    sed -i "s#{hudi_module_home}#$hudi_module_home#g" /usr/local/bin/hudistop && \
    chmod +x /usr/local/bin/hudirestart && chmod +x /usr/local/bin/hudistart && chmod +x /usr/local/bin/hudistop && \

## init service
    echo "hudistart" >> /init_service