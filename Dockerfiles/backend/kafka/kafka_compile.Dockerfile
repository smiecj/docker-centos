ARG JAVA_IMAGE
FROM ${JAVA_IMAGE}

ARG repo_home=/home/repo
ARG java_repo_home=${repo_home}/java

# env
ARG kafka_short_version=3.2
ARG scala_version=2.13

# ARG apache_repo=https://downloads.apache.org
ARG apache_repo=https://mirrors.tuna.tsinghua.edu.cn/apache
ARG kafka_repo=${apache_repo}/kafka

ARG kafka_code_pkg=kafka-${kafka_version}-src.tgz
ARG kafka_code_tmp_home=/tmp/kafka
ARG kafka_code_folder=kafka-${kafka_version}-src

ARG kafka_module_home=/opt/modules/kafka
ARG kafka_scripts_home=${kafka_module_home}/scripts

ENV zookeeper_server=127.0.0.1:2181
ENV bootstrap_servers=localhost:9092
ENV broker_port=9092
ENV jmx_port=9989
ENV MODE=singleton
ENV ID=0

# compile kafka
RUN mkdir -p ${kafka_module_home} && mkdir -p ${kafka_code_tmp_home} && cd ${kafka_code_tmp_home} && \
    kafka_version=`curl -L ${kafka_repo} | grep ">${kafka_short_version}" | sed 's#/<.*##g' | sed 's#.*>##g'` && \
    kafka_source_folder=kafka-${kafka_version}-src && \
    kafka_source_pkg=${kafka_source_folder}.tgz && \
    kafka_source_pkg_url=${kafka_repo}/${kafka_version}/${kafka_source_pkg} && \
    kafka_folder=kafka_${scala_version}-${kafka_version} && \
    kafka_pkg=${kafka_folder}.tgz && \
    curl -LO ${kafka_source_pkg_url} && tar -xvf ${kafka_source_pkg} && rm ${kafka_source_pkg} && \
    cd ${kafka_source_folder} && source /etc/profile && ./gradlew releaseTarGz -x test && \
    cp ./core/build/distributions/${kafka_pkg} ${kafka_module_home} && \
    cd ${kafka_module_home} && tar -xvf ${kafka_pkg} && mv ${kafka_folder}/* ./ && rm -rf ${kafka_folder} && rm -f ${kafka_pkg} && \
    rm -rf ${kafka_code_tmp_home} && rm -rf ${java_repo_home}

# scripts
COPY ./scripts/kafka-start.sh /usr/local/bin/kafkastart
RUN sed -i "s#{kafka_module_home}#${kafka_module_home}#g" /usr/local/bin/kafkastart
RUN chmod +x /usr/local/bin/kafkastart

COPY ./scripts/kafka-restart.sh /usr/local/bin/kafkarestart
RUN chmod +x /usr/local/bin/kafkarestart

COPY ./scripts/kafka-stop.sh /usr/local/bin/kafkastop
RUN chmod +x /usr/local/bin/kafkastop

RUN mkdir -p ${kafka_scripts_home}
COPY ./scripts/init-kafka.sh ${kafka_scripts_home}/
RUN sed -i "s#{kafka_module_home}#${kafka_module_home}#g" ${kafka_scripts_home}/init-kafka.sh
RUN chmod +x ${kafka_scripts_home}/init-kafka.sh

# jmx
RUN sed -i "s/esac/esac\nexport JMX_PORT={PORT}/g" ${kafka_module_home}/bin/kafka-server-start.sh

### add zookeeper start to entrypoint
RUN echo "${kafka_scripts_home}/init-kafka.sh && kafkastart" >> /init_service
