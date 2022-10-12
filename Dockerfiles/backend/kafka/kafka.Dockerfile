ARG JAVA_IMAGE
FROM ${JAVA_IMAGE}

# env
ARG kafka_short_version=3.2
ARG scala_version=2.13
# ARG apache_repo=https://downloads.apache.org
ARG apache_repo=https://mirrors.tuna.tsinghua.edu.cn/apache
ARG kafka_repo=${apache_repo}/kafka

ARG kafka_module_home=/opt/modules/kafka
ARG kafka_scripts_home=${kafka_module_home}/scripts

ENV zookeeper_server=127.0.0.1:2181
ENV bootstrap_servers=localhost:9092
ENV broker_port=9092
ENV jmx_port=9989
ENV MODE=singleton
ENV ID=0

# install kafka
RUN mkdir -p ${kafka_module_home} && cd ${kafka_module_home} && \
    kafka_version=`curl -L ${kafka_repo} | grep ">${kafka_short_version}" | sed 's#/<.*##g' | sed 's#.*>##g'` && \
    kafka_folder=kafka_${scala_version}-${kafka_version} && \
    kafka_pkg=${kafka_folder}.tgz && \
    kafka_pkg_url=${kafka_repo}/${kafka_version}/${kafka_pkg} && \
    curl -LO ${kafka_pkg_url} && tar -xvf ${kafka_pkg} && mv ${kafka_folder}/* ./ && rm -rf ${kafka_folder} && rm -f ${kafka_pkg}

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
