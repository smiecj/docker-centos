ARG IMAGE_JAVA
FROM ${IMAGE_JAVA}

ARG apache_repo
ARG module_home

# env
ARG kafka_version
ARG scala_version

ENV zookeeper_server=127.0.0.1:2181
ENV bootstrap_servers=localhost:9092
ENV broker_port=9092
ENV jmx_port=9989
ENV MODE=singleton
ENV ID=0

# scripts
COPY ./scripts/kafka-start.sh /usr/local/bin/kafkastart
COPY ./scripts/kafka-restart.sh /usr/local/bin/kafkarestart
COPY ./scripts/kafka-stop.sh /usr/local/bin/kafkastop
COPY ./scripts/init-kafka.sh ${kafka_scripts_home}/

# compile kafka
RUN kafka_module_home=${module_home}/kafka && \
    kafka_scripts_home=${kafka_module_home}/scripts && \
    kafka_code_tmp_home=/tmp/kafka && \
    kafka_code_folder=kafka-${kafka_version}-src && \
    kafka_repo=${apache_repo}/kafka && \
    mkdir -p ${kafka_scripts_home} && \
    mkdir -p ${kafka_module_home} && mkdir -p ${kafka_code_tmp_home} && cd ${kafka_code_tmp_home} && \
    kafka_long_version=`curl -L ${kafka_repo} | grep ">${kafka_version}" | sed 's#/<.*##g' | sed 's#.*>##g'` && \
    kafka_source_folder=kafka-${kafka_long_version}-src && \
    kafka_source_pkg=${kafka_source_folder}.tgz && \
    kafka_source_pkg_url=${kafka_repo}/${kafka_long_version}/${kafka_source_pkg} && \
    kafka_folder=kafka_${scala_version}-${kafka_long_version} && \
    kafka_pkg=${kafka_folder}.tgz && \
    curl -LO ${kafka_source_pkg_url} && tar -xvf ${kafka_source_pkg} && rm ${kafka_source_pkg} && \
    cd ${kafka_source_folder} && source /etc/profile && ./gradlew releaseTarGz -x test && \
    cp ./core/build/distributions/${kafka_pkg} ${kafka_module_home} && \
    cd ${kafka_module_home} && tar -xvf ${kafka_pkg} && mv ${kafka_folder}/* ./ && rm -rf ${kafka_folder} && rm -f ${kafka_pkg} && \
    rm -rf ${kafka_code_tmp_home} && \

    mv /tmp/init-kafka.sh ${kafka_scripts_home}/ && \
    sed -i "s#{kafka_module_home}#${kafka_module_home}#g" /usr/local/bin/kafkastart && \
    chmod +x /usr/local/bin/kafkastart && \
    chmod +x /usr/local/bin/kafkarestart && \
    chmod +x /usr/local/bin/kafkastop && \
    chmod +x ${kafka_scripts_home}/init-kafka.sh && \
    sed -i "s#{kafka_module_home}#${kafka_module_home}#g" ${kafka_scripts_home}/init-kafka.sh && \

# jmx
    sed -i "s/esac/esac\nexport JMX_PORT={PORT}/g" ${kafka_module_home}/bin/kafka-server-start.sh && \

### add zookeeper start to entrypoint
    echo "${kafka_scripts_home}/init-kafka.sh && kafkastart" >> /init_service
