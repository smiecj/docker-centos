ARG IMAGE_JAVA
FROM ${IMAGE_JAVA}

ARG module_home
ARG github_url
ARG flink_short_version
ARG flink_spark_version

# install flink
ENV rest_port=8081
ENV jobmanager_host=localhost
ENV jobmanager_port=6123
ENV workers=localhost
ENV masters=localhost
ENV FLINK_START=flinkstart

## config and script
COPY ./conf/flink-conf-example.yaml /tmp
COPY ./scripts/init-flink.sh /tmp

## scripts
COPY ./scripts/flink-restart.sh /usr/local/bin/flinkrestart
COPY ./scripts/flink-start.sh /usr/local/bin/flinkstart
COPY ./scripts/flink-stop.sh /usr/local/bin/flinkstop
COPY ./scripts/flink-not-start.sh /usr/local/bin/flinknotstart

# compile flink
RUN flink_module_home=${module_home}/flink && mkdir -p ${flink_module_home} && \
    cd /tmp && git clone ${github_url}/apache/flink -b release-${flink_short_version} && \
    cd flink && mvn clean package -DskipTests && \
    mv flink-dist/target/flink-${flink_short_version}-SNAPSHOT-bin/flink-${flink_short_version}-SNAPSHOT/* ${flink_module_home}/ && \
    cd ${flink_module_home} && rm -r /tmp/flink && \
    sed -i "s#ssh #ssh -o StrictHostKeyChecking=no #g" bin/*.sh && \
    echo -e """\n\
# flink\n\
export FLINK_HOME=${flink_module_home}\n\
export PATH=\$PATH:\$FLINK_HOME/bin\n\
""" >> /etc/profile && \

## gen ssh key (for multiple worker)
    ssh-keygen -t rsa -N '' -f $HOME/.ssh/id_rsa && \
    cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys && \
    chmod 0600 $HOME/.ssh/authorized_keys && \

## init service
    mv /tmp/init-flink.sh ${flink_module_home}/ && \
    mv /tmp/flink-conf-example.yaml ${flink_module_home}/conf/ && \
    sed -i "s#{flink_module_home}#${flink_module_home}#g" ${flink_module_home}/init-flink.sh && \
    sed -i "s#{flink_module_home}#${flink_module_home}#g" /usr/local/bin/flinkstart && \
    sed -i "s#{flink_module_home}#${flink_module_home}#g" /usr/local/bin/flinkstop && \
    chmod +x /usr/local/bin/flink* && \
    echo "/init_ssh_service" >> /init_service && \
    echo "sh ${flink_module_home}/init-flink.sh && nohup \${FLINK_START} > /dev/null 2>&1 &" >> /init_service