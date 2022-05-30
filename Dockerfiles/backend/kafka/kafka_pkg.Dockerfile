FROM centos_java

# env
ARG kafka_version=3.2.0
ARG scala_version=2.13
ARG kafka_pkg_url=https://mirrors.tuna.tsinghua.edu.cn/apache/kafka/${kafka_version}/kafka_${scala_version}-${kafka_version}.tgz
ARG kafka_module_home=/home/modules/kafka
ARG kafka_scripts_home=${kafka_module_home}/scripts
ARG kafka_pkg=kafka_${scala_version}-${kafka_version}.tgz
ARG kafka_pkg_folder=kafka_${scala_version}-${kafka_version}

ENV zookeeper_server=127.0.0.1:2181
ENV bootstrap_servers=localhost:9092
ENV broker_port=9092
ENV MODE=singleton
ENV ID=0

# install kafka
RUN mkdir -p ${kafka_module_home} && cd ${kafka_module_home} && \
    curl -LO ${kafka_pkg_url} && tar -xvf ${kafka_pkg} && rm -f ${kafka_pkg}

# scripts
COPY ./scripts/kafka-start.sh /usr/local/bin/kafkastart
RUN sed -i "s#{kafka_home}#${kafka_module_home}/${kafka_pkg_folder}#g" /usr/local/bin/kafkastart
RUN chmod +x /usr/local/bin/kafkastart

COPY ./scripts/kafka-restart.sh /usr/local/bin/kafkarestart
RUN chmod +x /usr/local/bin/kafkarestart

COPY ./scripts/kafka-stop.sh /usr/local/bin/kafkastop
RUN chmod +x /usr/local/bin/kafkastop

RUN mkdir -p ${kafka_scripts_home}
COPY ./scripts/init-kafka.sh ${kafka_scripts_home}/
RUN sed -i "s#{kafka_home}#${kafka_module_home}/${kafka_pkg_folder}#g" ${kafka_scripts_home}/init-kafka.sh
RUN chmod +x ${kafka_scripts_home}/init-kafka.sh

### add zookeeper start to entrypoint
RUN echo "${kafka_scripts_home}/init-kafka.sh && kafkastart" >> /init_service
