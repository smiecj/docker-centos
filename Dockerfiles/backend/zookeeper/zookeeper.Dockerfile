FROM centos_java AS java_base

# zookeeper config
ARG zookeeper_home=/home/modules/zookeeper
ARG zookeeper_scripts_home=$zookeeper_home/scripts
ARG zookeeper_tag=release-3.6.3
ARG zookeeper_tag_num=3.6.3

ARG zookeeper_source_url=https://github.com/apache/zookeeper/archive/refs/tags/$zookeeper_tag.tar.gz
ARG zookeeper_source_pkg=zookeeper_code.tar.gz
ARG zookeeper_source_folder=zookeeper-$zookeeper_tag
ARG zookeeper_pkg=apache-zookeeper-$zookeeper_tag_num-bin.tar.gz
ARG zookeeper_folder=apache-zookeeper-$zookeeper_tag_num-bin

ENV MODE=singleton
ENV MYID=1
ENV PORT=2181
ENV zookeeper_data_home=${zookeeper_home}/${zookeeper_folder}/data
ENV SERVER_INFO={zk_host_1}:2888:3888,{zk_host_2}:2888:3888,{zk_host_3}:2888:3888

ARG repo_home=/home/repo
ARG java_repo_home=${repo_home}/java

# download zookeeper source code and compile
RUN mkdir -p ${zookeeper_home}
RUN cd ${zookeeper_home} && curl -L $zookeeper_source_url -o $zookeeper_source_pkg \
  && tar -xzvf $zookeeper_source_pkg && rm -f $zookeeper_source_pkg

RUN source /etc/profile && cd ${zookeeper_home}/${zookeeper_source_folder} && \
    mvn clean install -DskipTests && mv zookeeper-assembly/target/$zookeeper_pkg ${zookeeper_home}/

RUN cd ${zookeeper_home} && tar -xzvf $zookeeper_pkg && rm -f $zookeeper_pkg

# copy cfg
COPY zoo_*.cfg ${zookeeper_home}/${zookeeper_folder}/conf/

### copy zk init script and add to entrypoint
COPY ./scripts/init-zookeeper.sh ${zookeeper_home}/${zookeeper_folder}/
RUN echo "sh ${zookeeper_home}/${zookeeper_folder}/init-zookeeper.sh" >> /init_service

## clean mvn download packages
RUN rm -rf ${java_repo_home}/maven/*

# zookeeper service

## zookeeper start and stop script
### sed can set split character, refer: https://stackoverflow.com/a/26603752
COPY ./scripts/zookeeper-start.sh /usr/local/bin/zookeeperstart
RUN sed -i "s#{zookeeper_home}#${zookeeper_home}/${zookeeper_folder}#g" /usr/local/bin/zookeeperstart && \
    chmod +x /usr/local/bin/zookeeperstart

COPY ./scripts/zookeeper-restart.sh /usr/local/bin/zookeeperrestart
RUN chmod +x /usr/local/bin/zookeeperrestart

COPY ./scripts/zookeeper-stop.sh /usr/local/bin/zookeeperstop
RUN chmod +x /usr/local/bin/zookeeperstop

### add zookeeper start to entrypoint
RUN echo "zookeeperstart" >> /init_service

RUN rm -rf /tmp/*
