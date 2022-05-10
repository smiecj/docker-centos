FROM centos_java AS java_base

# install hudi
ARG hudi_module_home=/home/modules/hudi

ARG hudi_version=0.10.1
ARG hudi_source_code_url=https://github.com/apache/hudi/archive/refs/tags/release-${hudi_version}.tar.gz
ARG hudi_source_pkg=release-${hudi_version}.tar.gz
ARG hudi_source_folder=hudi-release-${hudi_version}
ARG hudi_source_home=${hudi_module_home}/${hudi_source_folder}
ARG hudi_log=${hudi_module_home}/hudi.log

ARG spark_version=2.4.8
ARG hadoop_version=2.7
# ARG spark_pkg_url=https://archive.apache.org/dist/spark/spark-${spark_version}/spark-${spark_version}-bin-hadoop${hadoop_version}.tgz
ARG spark_pkg_url=https://mirrors.tuna.tsinghua.edu.cn/apache/spark/spark-${spark_version}/spark-${spark_version}-bin-hadoop${hadoop_version}.tgz
ARG spark_pkg=spark-${spark_version}-bin-hadoop${hadoop_version}.tgz
ARG spark_module_folder=spark-${spark_version}-bin-hadoop${hadoop_version}

## download source code
RUN mkdir -p ${hudi_module_home}
RUN cd ${hudi_module_home} && curl -LO $hudi_source_code_url && \
    tar -xzvf ${hudi_source_pkg} && rm -f ${hudi_source_pkg}

## compile
RUN cd ${hudi_source_home} && source /etc/profile && mvn clean package -DskipTests
RUN cd ${hudi_source_home} && mv packaging/* ${hudi_module_home} && rm -rf ${hudi_source_home}

## spark download
RUN cd ${hudi_module_home} && curl -LO $spark_pkg_url && \
    tar -xvf $spark_pkg && rm -f $spark_pkg

## add and enable hudi service
COPY ./scripts/hudi-restart.sh /usr/local/bin/hudirestart
COPY ./scripts/hudi-start.sh /usr/local/bin/hudistart
COPY ./scripts/hudi-stop.sh /usr/local/bin/hudistop
RUN sed -i "s#{hudi_module_home}#$hudi_module_home#g" /usr/local/bin/hudistart && \
    sed -i "s#{spark_module_folder}#$spark_module_folder#g" /usr/local/bin/hudistart && \
    sed -i "s#{hudi_module_home}#$hudi_module_home#g" /usr/local/bin/hudistop
RUN chmod +x /usr/local/bin/hudirestart && chmod +x /usr/local/bin/hudistart && chmod +x /usr/local/bin/hudistop

## init service
RUN echo "hudistart" >> /init_service