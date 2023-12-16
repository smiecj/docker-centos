ARG IMAGE_JAVA
FROM ${IMAGE_JAVA}

ARG module_home

ARG zookeeper_version
ARG apache_repo

ENV MODE=singleton
ENV MYID=1
ENV PORT=2181
ENV zookeeper_data_home=/opt/data/zookeeper
ENV SERVER_INFO=
# {zk_host_1}:2888:3888,{zk_host_2}:2888:3888,{zk_host_3}:2888:3888

# copy script
COPY ./scripts/ /tmp

# copy cfg
COPY zoo_*.cfg /tmp

# download zookeeper source code and compile
RUN zookeeper_module_home=${module_home}/zookeeper && \
    zookeeper_pkg_folder=apache-zookeeper-${zookeeper_version}-bin && \
    zookeeper_pkg=${zookeeper_pkg_folder}.tar.gz && \
    zookeeper_pkg_url=${apache_repo}/zookeeper/zookeeper-${zookeeper_version}/${zookeeper_pkg} && \
    mkdir -p ${zookeeper_module_home} && cd ${zookeeper_module_home} && \
    curl -LO ${zookeeper_pkg_url} && tar -xzvf ${zookeeper_pkg} && rm ${zookeeper_pkg} && \
    mv ${zookeeper_pkg_folder}/* ./ && rm -r ${zookeeper_pkg_folder} && \

    mv /tmp/zookeeper-start.sh /usr/local/bin/zookeeperstart && \
    mv /tmp/zookeeper-stop.sh /usr/local/bin/zookeeperstop && \
    mv /tmp/zookeeper-restart.sh /usr/local/bin/zookeeperrestart && \
    mv /tmp/init-zookeeper.sh ${zookeeper_module_home}/ && \
    mv /tmp/zoo_*.cfg ${zookeeper_module_home}/conf/ && \
    echo "sh ${zookeeper_module_home}/init-zookeeper.sh" >> /init_service && \
    sed -i "s#{zookeeper_module_home}#${zookeeper_module_home}#g" /usr/local/bin/zookeeperstart && \
    chmod +x /usr/local/bin/zookeeper* && \
    echo "zookeeperstart" >> /init_service