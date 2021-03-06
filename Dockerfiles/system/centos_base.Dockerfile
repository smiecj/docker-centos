FROM centos:centos8.4.2105

MAINTAINER smiecj smiecj@github.com

ARG ROOT_PWD=root!centos123

# init system
USER root
ENV HOME /root

COPY init-*.sh /tmp/
COPY env_*.sh /tmp/

## bashrc
RUN sed -i "s/alias cp/#alias cp/g" ~/.bashrc
RUN sed -i "s/alias mv/#alias mv/g" ~/.bashrc
RUN echo "alias ll='ls -l'" >> ~/.bashrc
RUN echo "alias rm='rm -f'" >> ~/.bashrc
RUN echo "source /etc/profile" >> ~/.bashrc

## yum
COPY yum /tmp/yum
RUN sh /tmp/init-system-yum.sh
RUN rm -rf /tmp/yum

## install basic components
### epel refer: https://docs.fedoraproject.org/en-US/epel/
RUN yum -y install epel-release

### initscripts refer: https://yum-info.contradodigital.com/view-package/installed/initscripts/
RUN yum -y install initscripts

### some compile basic package
RUN yum -y install libncurses* libaio numactl

### sshd
RUN yum -y install openssh-server openssh-clients openssl openssl-devel compat-openssl10
#systemctl enable sshd

### gcc & make
RUN yum -y install make
RUN yum -y install gcc
RUN yum -y install gcc-c++
RUN yum -y install cmake

### other useful tools
RUN yum -y install lsof net-tools vim lrzsz zip unzip bzip2 ncurses git wget sudo passwd
RUN yum -y install expect jq telnet net-tools rsync logrotate

#### git config
RUN git config --global pull.rebase false

### devel pkg
RUN yum -y install cyrus-sasl cyrus-sasl-devel
RUN yum -y install python3-devel
RUN yum -y install libffi-devel
RUN yum -y install freetds-devel
RUN yum -y install mysql-devel unixODBC-devel
RUN yum -y install libxml2 libxml2-devel
RUN yum -y install libxslt libxslt-devel

## set docker inner proxy
RUN sh /tmp/init-system-proxy.sh

## zsh
RUN sh /tmp/init-system-zsh.sh

## vim support utf-8
RUN echo "set encoding=utf-8 fileencodings=ucs-bom,utf-8,cp936" >> ~/.vimrc

## set login password
RUN echo root:${ROOT_PWD} | chpasswd

## history
RUN echo "export HISTCONTROL=ignoredups" >> /etc/profile

## timezone
RUN cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

RUN rm -f /tmp/init-*.sh && rm -f /tmp/env_*.sh

## s6
ARG s6_version=v2.2.0.3
COPY init-system-s6.sh /tmp/
RUN sh /tmp/init-system-s6.sh
RUN rm /tmp/init-system-s6.sh

### s6 with crontab
RUN yum -y install crontabs
COPY s6/ /etc

## add `add logrotate task` command
RUN mkdir -p /tmp/bin
COPY command/ /tmp/bin/
RUN chmod -R 755 /tmp/bin && mv /tmp/bin/* /usr/local/bin && rm -rf /tmp/bin

## init and child dockerfile endpoint
### child dockerfile service init can add to /init_service script (append)
### https://stackoverflow.com/questions/2518127/how-to-reload-bashrc-settings-without-logging-out-and-back-in-again
RUN echo -e """#!/bin/bash\n\
sh /init_service\n\
exec /init\n\
""" > /init_system && chmod +x /init_system

RUN echo -e """#!/bin/bash\n\
echo 'hello docker centos'\n\
. /etc/profile\n\
\n\
## child dockerfile init append after this\n\
""" > /init_service && chmod +x /init_service

ENTRYPOINT ["/init_system"]