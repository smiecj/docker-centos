# 第一行：指定需要拉取的镜像版本
FROM mzsmieli/centos_dev:v1.0.0

# 本地测试dockerfile文件，从阿里云镜像中拉取最新版本
# VERSION 1 -- for test
# Author: ShuaiFeng
# Command Format

# WORKDIR 指定镜像内部的工作路径，在执行COPY、ADD的时候需要用到
WORKDIR /home/coding

# 设置镜像的作者
MAINTAINER lifeng 123@qq.com

ENV ROOT_PWD=$ROOT_PWD

# RUN 
## 预装一些常用指令
RUN yum -y install expect epel-release jq \
    && rm -f main.zip && rm -rf docker-centos-main && wget https://github.com/smiecj/docker-centos/archive/refs/heads/main.zip && unzip main.zip \
    && cp -f docker-centos-main/scripts/init-system.sh /usr/sbin/init-system \
    && chmod +x /usr/sbin/init-system

# ENTRYPOINT 一定会执行的初始化语句
ENTRYPOINT ["/usr/sbin/init-system"]

# EXPOSE 说明镜像启动之后，其对应的服务需要对外开放的端口，这里指定的是内部端口
EXPOSE 22