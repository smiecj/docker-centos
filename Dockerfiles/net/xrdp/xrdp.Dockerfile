FROM centos:centos8.4.2105

ARG HOME=/root

ARG yum_repo=http://mirrors.tuna.tsinghua.edu.cn/centos-vault
ARG module_home

# fix yum
RUN sed -i -e "s|mirrorlist=|#mirrorlist=|g" /etc/yum.repos.d/CentOS-* && \
    sed -i -e "s|#baseurl=http://mirror.centos.org|baseurl=${yum_repo}|g" /etc/yum.repos.d/CentOS-* && \

# install basic component
    yum -y update && \
    yum -y install epel-release vim lsof curl && \
    yum -y install xrdp && \
    yum -y install lrzsz && \

# xfce
    yum -y groupinstall Xfce && \
    echo "xfce4-session" > ~/.Xclients && chmod +x ~/.Xclients && \

## system
    systemctl enable xrdp

# root pwd
ARG root_pwd=root_123
RUN yum -y install passwd && \
    echo root:${root_pwd} | chpasswd
