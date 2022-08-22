# a centos image smaller than centos_base only include yum repo fix and some basic component
# for deploy simple service (such as wordpress)
ARG version=8.4.2105
FROM centos:centos${version}

MAINTAINER smiecj smiecj@github.com

ARG ROOT_PWD=root!centos123

# init system
USER root
ENV HOME /root

COPY init-system-yum.sh /tmp/
COPY init-system-s6.sh /tmp/

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

### fix: Unexpected key in data: static_context
RUN if [[ ${version} =~ 8.* ]]; then dnf -y update libmodulemd; fi

## install basic components
### epel refer: https://docs.fedoraproject.org/en-US/epel/
RUN yum -y install epel-release

### make
RUN yum -y install make

### other useful tools
RUN yum -y install lsof net-tools vim lrzsz zip unzip git wget
RUN yum -y install telnet logrotate

#### git config
RUN git config --global pull.rebase false

## copy proxy init script
COPY init-system-proxy.sh /init_system_proxy
RUN chmod +x /init_system_proxy
ENV HAS_PROXY "false"

## vim support utf-8
RUN echo "set encoding=utf-8 fileencodings=ucs-bom,utf-8,cp936" >> ~/.vimrc

## set login password
RUN echo root:${ROOT_PWD} | chpasswd

## history
RUN echo "export HISTCONTROL=ignoredups" >> /etc/profile

## timezone
RUN cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

RUN rm -f /tmp/init-*.sh

## s6
ARG s6_version=v2.2.0.3
COPY init-system-s6.sh /tmp/
RUN sh /tmp/init-system-s6.sh
### check s6 is install success
RUN ls -l /init
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
/init_system_proxy\n\
""" > /init_service && chmod +x /init_service

ENTRYPOINT ["/init_system"]