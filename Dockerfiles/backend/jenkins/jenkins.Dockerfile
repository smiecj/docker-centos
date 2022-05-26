FROM centos_java AS java_base

# jenkins config
ARG jenkins_version=2.332.3-1.1
ARG jenkins_download_url=https://mirrors.tuna.tsinghua.edu.cn/jenkins/redhat-stable/jenkins-${jenkins_version}.noarch.rpm
ARG jenkins_rpm_pkg=jenkins.rpm
ENV PORT=8089

ARG jenkins_module_home=/home/modules/jenkins
ARG jenkins_log=${jenkins_module_home}/jenkins.log

# install jenkins
RUN cd /tmp && curl -L ${jenkins_download_url} -o ${jenkins_rpm_pkg} && rpm -ivh ${jenkins_rpm_pkg} && rm -f ${jenkins_rpm_pkg}
RUN mkdir -p ${jenkins_module_home}

# fix libfreetype.so.6 not found
RUN yum -y install freetype freetype-devel

# fix fontconf null pointer exception
## https://github.com/AdoptOpenJDK/openjdk-docker/issues/75
RUN yum -y install fontconfig && fc-cache --forc

# install docker (for docker in docker)
RUN yum install -y yum-utils

RUN yum-config-manager \
    --add-repo \
    https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo && \
    sed -i 's/download.docker.com/mirrors.aliyun.com\/docker-ce/g' /etc/yum.repos.d/docker-ce.repo

RUN yum install -y docker-ce-cli

## user jenkins add to docker group (to access /var/run/docker.sock)
RUN usermod -a -G docker jenkins
## for docker in docker, must set 777 to sock
RUN chmod 777 /var/run/docker.sock

# scripts
COPY ./scripts/jenkins-start.sh /usr/local/bin/jenkinsstart
RUN chmod +x /usr/local/bin/jenkinsstart
RUN sed -i "s#{jenkins_log}#${jenkins_log}#g" /usr/local/bin/jenkinsstart

COPY ./scripts/jenkins-restart.sh /usr/local/bin/jenkinsrestart
RUN chmod +x /usr/local/bin/jenkinsrestart

COPY ./scripts/jenkins-stop.sh /usr/local/bin/jenkinsstop
RUN chmod +x /usr/local/bin/jenkinsstop

# init service
RUN echo "jenkinsstart" >> /init_service
RUN addlogrotate ${jenkins_log} jenkins

# 源替换（需要服务启动后执行）
# RUN sed -i 's#https://updates.jenkins.io/download#https://mirrors.tuna.tsinghua.edu.cn/jenkins#g' /var/lib/jenkins/.jenkins/updates/default.json && sed -i 's#http://www.google.com#https://www.baidu.com#g' /var/lib/jenkins/.jenkins/updates/default.json
