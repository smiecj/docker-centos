ARG JAVA_IMAGE
FROM ${JAVA_IMAGE}

# env
ARG kafka_version=3.2.0
ARG scala_version=2.13
ARG kafka_code_url=https://mirrors.tuna.tsinghua.edu.cn/apache/kafka/${kafka_version}/kafka-${kafka_version}-src.tgz
ARG kafka_code_pkg=kafka-${kafka_version}-src.tgz
ARG kafka_code_home=/tmp
ARG kafka_code_folder=kafka-${kafka_version}-src

ARG kafka_module_home=/home/modules/kafka
ARG kafka_scripts_home=${kafka_module_home}/scripts
ARG kafka_pkg=kafka_${scala_version}-${kafka_version}.tgz
ARG kafka_pkg_folder=kafka_${scala_version}-${kafka_version}

ENV zookeeper_server=127.0.0.1:2181
ENV bootstrap_servers=localhost:9092
ENV broker_port=9092
ENV MODE=singleton
ENV ID=0

# compile kafka
RUN mkdir -p ${kafka_module_home}
RUN mkdir -p ${kafka_code_home} && cd ${kafka_code_home} && \
    curl -LO ${kafka_code_url} && tar -xvf ${kafka_code_pkg} && rm -f ${kafka_code_pkg}
RUN cd ${kafka_code_home}/${kafka_code_folder} && \
    source /etc/profile && ./gradlew releaseTarGz -x test && \
    cp ./core/build/distributions/${kafka_pkg} ${kafka_module_home}

RUN rm -rf ${kafka_code_home}/${kafka_code_folder}
RUN cd ${kafka_module_home} && tar -xvf ${kafka_pkg} && rm -f ${kafka_pkg}

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
