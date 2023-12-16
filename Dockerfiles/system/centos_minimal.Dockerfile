# a centos image smaller than centos_base only include yum repo fix and some basic component
# for deploy simple service (such as wordpress)
ARG IMAGE_CENTOS
FROM ${IMAGE_CENTOS}

ARG ROOT_PWD=root!centos123

# init system
USER root
ENV HOME /root

COPY init-system-yum.sh /tmp/
COPY init-system-s6.sh /tmp/

## bashrc
RUN sed -i "s/alias cp/#alias cp/g" ~/.bashrc && \
    sed -i "s/alias mv/#alias mv/g" ~/.bashrc && \
    echo "alias ll='ls -l'" >> ~/.bashrc && \
    echo "alias rm='rm -f'" >> ~/.bashrc && \
    echo "source /etc/profile" >> ~/.bashrc

## yum
COPY yum /tmp/yum
RUN sh /tmp/init-system-yum.sh && \
    rm -rf /tmp/yum

### fix: Unexpected key in data: static_context
RUN if [[ ${version} =~ 8.* ]]; then dnf -y update libmodulemd; fi && \

## install basic components
### epel refer: https://docs.fedoraproject.org/en-US/epel/
    yum -y install epel-release \

### make
    make \

### zh_cn locale
    glibc-common langpacks-zh_CN \

### other useful tools
    lsof net-tools vim lrzsz zip unzip git wget \
    telnet logrotate && \

#### git config
    git config --global pull.rebase false

## copy proxy init script
COPY init-system-proxy.sh /init_system_proxy
ENV HAS_PROXY "false"

## copy repo
COPY init-repo.sh /init_repo
COPY ./repo/ /

## vim support utf-8
RUN echo "set encoding=utf-8 fileencodings=ucs-bom,utf-8,cp936" >> ~/.vimrc && \

## set login password
    echo root:${ROOT_PWD} | chpasswd && \

## history
    echo "export HISTCONTROL=ignoredups" >> /etc/profile && \

## timezone
    cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \

    rm -f /tmp/init-*.sh

## s6
ARG s6_version
ARG github_url
COPY init-system-s6.sh /tmp/
RUN github_url=${github_url} sh /tmp/init-system-s6.sh && \
### check s6 is install success
    ls -l /init && \
    rm /tmp/init-system-s6.sh && \
### s6 with crontab
    yum -y install crontabs && \
### s6 with syslog
    yum -y install rsyslog

COPY s6/ /etc

## add `add logrotate task` command
COPY command/ /usr/local/bin/
RUN chmod +x /usr/local/bin/*

## init and child dockerfile endpoint
### child dockerfile service init can add to /init_service script (append)
### https://stackoverflow.com/questions/2518127/how-to-reload-bashrc-settings-without-logging-out-and-back-in-again
RUN echo -e """#!/bin/bash\n\
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
""" > /init_service

## add execute permission
RUN chmod +x /init_system_proxy && \
    chmod +x /init_repo && \
    chmod +x /init_system && \
    chmod +x /init_service

ENTRYPOINT ["/init_system"]