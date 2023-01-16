ARG IMAGE_JAVA
FROM ${IMAGE_JAVA} AS java_base

# zookeeper config
ARG module_home

ARG ZOOKEEPER_VERSION
ARG github_repo

ENV MODE=singleton
ENV MYID=1
ENV PORT=2181
ENV zookeeper_data_home=/opt/data/zookeeper
ENV SERVER_INFO={zk_host_1}:2888:3888,{zk_host_2}:2888:3888,{zk_host_3}:2888:3888

# copy script
COPY ./scripts/zookeeper-start.sh /usr/local/bin/zookeeperstart
COPY ./scripts/zookeeper-restart.sh /usr/local/bin/zookeeperrestart
COPY ./scripts/zookeeper-stop.sh /usr/local/bin/zookeeperstop
COPY ./scripts/init-zookeeper.sh /tmp
# copy cfg
COPY zoo_*.cfg /tmp

# download zookeeper source code and compile
RUN zookeeper_home=${module_home}/zookeeper && \
    zookeeper_release_version=release-${ZOOKEEPER_VERSION} && \
    zookeeper_source_pkg=${zookeeper_release_version}.tar.gz && \
    zookeeper_source_url=${github_repo}/apache/zookeeper/archive/refs/tags/${zookeeper_source_pkg} && \
    zookeeper_source_folder=zookeeper-${zookeeper_release_version} && \
    zookeeper_pkg_folder=apache-zookeeper-${ZOOKEEPER_VERSION}-bin && \
    zookeeper_pkg=${zookeeper_pkg_folder}.tar.gz && \
    mkdir -p ${zookeeper_home} && \
    cd ${zookeeper_home} && curl -LO ${zookeeper_source_url} && \
    tar -xzvf ${zookeeper_source_pkg} && rm ${zookeeper_source_pkg} && \
    source /etc/profile && cd ${zookeeper_source_folder} && \
    mvn clean install -DskipTests && mv zookeeper-assembly/target/${zookeeper_pkg} ${zookeeper_home}/ && \
    cd ${zookeeper_home} && rm -r ${zookeeper_source_folder} && \
    tar -xzvf ${zookeeper_pkg} && rm $zookeeper_pkg && mv ${zookeeper_pkg_folder}/* ./ && rm -r ${zookeeper_pkg_folder} && \
### copy zk init script and conf
    mv /tmp/init-zookeeper.sh ${zookeeper_home}/ && \
    mv /tmp/zoo_*.cfg ${zookeeper_home}/conf/ && \
    echo "sh ${zookeeper_home}/init-zookeeper.sh" >> /init_service && \
## clean mvn download packages
    rm -rf ~/.m2/repository/* && \
# zookeeper service
    sed -i "s#{zookeeper_home}#${zookeeper_home}#g" /usr/local/bin/zookeeperstart && \
    chmod +x /usr/local/bin/zookeeperstart && chmod +x /usr/local/bin/zookeeperstop && chmod +x /usr/local/bin/zookeeperrestart && \
### add zookeeper start to entrypoint
    echo "zookeeperstart" >> /init_service && \
    rm -rf /tmp/*