FROM centos_minimal

MAINTAINER smiecj smiecj@github.com

USER root

# install java (minimal)

## args
ARG java_home=/usr/java
ARG repo_home=/home/repo
ARG java_repo_home=${repo_home}/java

COPY env_java.sh /tmp/

## install jdk8
RUN mkdir -p ${java_home}
RUN mkdir -p ${java_repo_home}
RUN cd ${java_home} && rm -rf *
RUN . /tmp/env_java.sh && source /etc/profile && cd ${java_home} && curl -LO $jdk_8_download_url && tar -xzvf $jdk_8_pkg && rm -f $jdk_8_pkg

## profile
RUN . /tmp/env_java.sh && echo -e '\n# java' >> /etc/profile && \
    echo "export JAVA_HOME=$java_home/$jdk_8_folder" >> /etc/profile && \
    echo 'export JRE_HOME=$JAVA_HOME/jre' >> /etc/profile && \
    echo 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib' >> /etc/profile  && \
    echo 'export PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin' >> /etc/profile

RUN rm -f /tmp/env_java.sh