ARG IMAGE_JAVA
FROM ${IMAGE_JAVA} AS java_base

# jenkins config
ARG jenkins_version
ARG jenkins_repo
ENV PORT=8089

ARG module_home

# scripts
COPY ./scripts/jenkins-start.sh /usr/local/bin/jenkinsstart
COPY ./scripts/jenkins-restart.sh /usr/local/bin/jenkinsrestart
COPY ./scripts/jenkins-stop.sh /usr/local/bin/jenkinsstop

# install jenkins
RUN jenkins_rpm_pkg=jenkins.rpm && \
    jenkins_module_home=${module_home}/jenkins && \
    jenkins_log=${jenkins_module_home}/jenkins.log && \
    jenkins_user_home=/var/lib/jenkins/.jenkins && \
    jenkins_war_home=${jenkins_user_home}/war && \
    jenkins_download_url=${jenkins_repo}/redhat-stable/jenkins-${jenkins_version}.noarch.rpm && \
    cd /tmp && curl -L ${jenkins_download_url} -o ${jenkins_rpm_pkg} && rpm -ivh ${jenkins_rpm_pkg} && rm ${jenkins_rpm_pkg} && \
    mkdir -p ${jenkins_module_home} && \

# fix libfreetype.so.6 not found
    yum -y install freetype freetype-devel && \

# fix fontconf null pointer exception
## https://github.com/AdoptOpenJDK/openjdk-docker/issues/75
    yum -y install fontconfig && fc-cache --force && \

# install docker client (for docker in docker)
    yum install -y yum-utils && \

    yum-config-manager \
    --add-repo \
    https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo && \
    sed -i 's/download.docker.com/mirrors.aliyun.com\/docker-ce/g' /etc/yum.repos.d/docker-ce.repo && \

    yum install -y docker-ce-cli && \

## user jenkins add to docker group (to access /var/run/docker.sock)
    usermod -a -G docker jenkins && \

## init .jenkins/war folder (for docker in docker)
    mkdir -p ${jenkins_war_home} && cp /usr/share/java/jenkins.war ${jenkins_war_home} && \
    cd ${jenkins_war_home} && unzip jenkins.war && rm jenkins.war && \
    chown -R jenkins:jenkins ${jenkins_user_home} && \

    chmod +x /usr/local/bin/jenkinsstart && \
    sed -i "s#{jenkins_log}#${jenkins_log}#g" /usr/local/bin/jenkinsstart && \
    chmod +x /usr/local/bin/jenkinsrestart && \
    chmod +x /usr/local/bin/jenkinsstop && \

# init service
    echo "jenkinsstart" >> /init_service && \
    addlogrotate ${jenkins_log} jenkins

# replace source repo
# RUN sed -i 's#https://updates.jenkins.io/download#https://mirrors.tuna.tsinghua.edu.cn/jenkins#g' /var/lib/jenkins/.jenkins/updates/default.json && sed -i 's#http://www.google.com#https://www.baidu.com#g' /var/lib/jenkins/.jenkins/updates/default.json
