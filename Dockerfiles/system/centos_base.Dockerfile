ARG CENTOS_VERSION
FROM centos:centos${CENTOS_VERSION}

ARG ROOT_PWD=root!centos123

# init system
USER root
ENV HOME /root
ENV INIT_SERVICE=

COPY init-*.sh /tmp/
COPY env_*.sh /tmp/
COPY yum /tmp/yum

## bashrc
RUN sed -i "s/alias cp/#alias cp/g" ~/.bashrc && \
    sed -i "s/alias mv/#alias mv/g" ~/.bashrc && \
    echo "alias ll='ls -l'" >> ~/.bashrc && \
    echo "alias rm='rm -f'" >> ~/.bashrc && \
    echo "source /etc/profile" >> ~/.bashrc && \
## yum
    sh /tmp/init-system-yum.sh && \
    rm -r /tmp/yum && \
## install basic components
### epel refer: https://docs.fedoraproject.org/en-US/epel/
    yum -y install epel-release \
### initscripts refer: https://yum-info.contradodigital.com/view-package/installed/initscripts/
    initscripts \
### some compile basic package
    libncurses* libaio numactl \
### sshd
    openssh-server openssh-clients openssl openssl-devel compat-openssl10 \
### gcc & make
    make gcc gcc-c++ cmake \
### other useful tools
    lsof net-tools vim lrzsz zip unzip bzip2 ncurses git wget sudo passwd \
    expect jq telnet net-tools rsync logrotate \
### devel pkg
    cyrus-sasl cyrus-sasl-devel libffi-devel \
    mysql-devel unixODBC-devel libxml2 libxml2-devel libxslt libxslt-devel && \
#### git config
    git config --global pull.rebase false

## copy proxy init script
COPY init-system-proxy.sh /init_system_proxy
ENV HAS_PROXY "false"

## copy repo
COPY init-repo.sh /init_repo
COPY ./repo/ /

## zsh
RUN sh /tmp/init-system-zsh.sh && \
## vim support utf-8
    echo "set encoding=utf-8 fileencodings=ucs-bom,utf-8,cp936" >> ~/.vimrc && \
## set login password
    echo root:${ROOT_PWD} | chpasswd && \
## history
    echo "export HISTCONTROL=ignoredups" >> /etc/profile && \
## timezone
    cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    rm -f /tmp/init-*.sh && rm -f /tmp/env_*.sh

## s6
ARG s6_version=v2.2.0.3
COPY init-system-s6.sh /tmp/
RUN sh /tmp/init-system-s6.sh && \
### check s6 is install success
    ls -l /init && \
    rm /tmp/init-system-s6.sh && \
### s6 with crontab
    yum -y install crontabs

COPY s6/ /etc

## add `add logrotate task` command
COPY command/ /usr/local/bin/
RUN chmod +x /usr/local/bin/* && \

## init and child dockerfile endpoint
### child dockerfile service init can add to /init_service script (append)
### https://stackoverflow.com/questions/2518127/how-to-reload-bashrc-settings-without-logging-out-and-back-in-again
    echo -e """#!/bin/bash\n\
sh /init_service\n\
exec /init\n\
""" > /init_system && \
echo -e """#!/bin/bash\n\
echo 'hello docker centos'\n\
. /etc/profile\n\
\n\
## child dockerfile init append after this\n\
/init_system_proxy\n\
/init_repo\n\
/init_ssh_service\n\
""" > /init_service

## init ssh
COPY ./scripts/sshd-start.sh /init_ssh_service

## add execute permission
RUN chmod +x /init_ssh_service && \
    chmod +x /init_repo && \
    chmod +x /init_system_proxy && \
    chmod +x /init_system && \
    chmod +x /init_service

ENTRYPOINT ["/init_system"]