FROM centos:centos8.4.2105

ARG yum_repo=http://mirrors.tuna.tsinghua.edu.cn/centos-vault

# fix yum
RUN sed -i -e "s|mirrorlist=|#mirrorlist=|g" /etc/yum.repos.d/CentOS-*
RUN sed -i -e "s|#baseurl=http://mirror.centos.org|baseurl=${yum_repo}|g" /etc/yum.repos.d/CentOS-*

# install basic component
RUN yum -y update
RUN yum -y install epel-release vim lsof curl
RUN yum -y install xrdp
RUN yum -y install lrzsz

# xfce
RUN yum -y groupinstall Xfce
RUN echo "xfce4-session" > ~/.Xclients && chmod +x ~/.Xclients

# system
RUN systemctl enable xrdp