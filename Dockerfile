# 第一行：指定需要拉取的镜像版本
FROM mzsmieli/centos_dev

# 本地测试dockerfile文件，从阿里云镜像中拉取最新版本
# VERSION 1 -- for test
# Author: ShuaiFeng
# Command Format

# WORKDIR 指定镜像内部的工作路径，在执行COPY、ADD的时候需要用到
WORKDIR /home

# 设置镜像的作者
MAINTAINER lifeng 123@qq.com

ENV HAHAHA="666"

# RUN 
RUN echo "build before start" >> /tmp/test.log

# ENTRYPOINT 一定会执行的初始化语句
ENTRYPOINT ["/usr/sbin/init", "/bin/bash", "echo $HAHAHA > /tmp/hahaha.log"]

# CMD 说明启动容器之后需要执行的指令
#CMD ["/bin/bash", "echo $HAHAHA > /tmp/hahaha.log"]

# EXPOSE 说明镜像启动之后，其对应的服务需要对外开放的端口，这里指定的是内部端口
EXPOSE 22

# 磁盘挂载点（？）
#VOLUME ["/home"]

# COPY 指令：将本机文件拷贝到镜像里面去
#COPY . ./music