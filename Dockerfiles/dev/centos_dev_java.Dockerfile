FROM centos_base AS base

MAINTAINER smiecj smiecj@github.com

USER root

# install java

## args
ARG java_home=/usr/java
ARG repo_home=/home/repo
ARG java_repo_home=${repo_home}/java

COPY env_java.sh /tmp/

## install jdk 8 & 11
RUN mkdir -p ${java_home}
RUN mkdir -p ${java_repo_home}
RUN cd ${java_home} && rm -rf *
RUN  . /tmp/env_java.sh && source /etc/profile && cd ${java_home} && curl -LO $jdk_11_download_url && tar -xzvf $jdk_11_pkg && rm -f $jdk_11_pkg
RUN . /tmp/env_java.sh && source /etc/profile && cd ${java_home} && curl -LO $jdk_8_download_url && tar -xzvf $jdk_8_pkg && rm -f $jdk_8_pkg

## maven
ARG maven_version=3.8.4
# https://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/3.8.5/source/apache-maven-3.8.5-src.zip
ARG maven_download_url=https://archive.apache.org/dist/maven/maven-3/${maven_version}/binaries/apache-maven-${maven_version}-bin.tar.gz
ARG maven_pkg=apache-maven-${maven_version}-bin.tar.gz

RUN cd ${java_home} && source /etc/profile && curl -L ${maven_download_url} -o ${maven_pkg} && \
    tar -xzvf ${maven_pkg} && \
    rm -f ${maven_pkg}

ARG maven_home=/usr/java/apache-maven-${maven_version}
ARG maven_repo=${java_repo_home}/maven
COPY ./maven/settings.xml ${maven_home}/conf

RUN maven_repo_replace_str=$(echo "$maven_repo" | sed 's/\//\\\//g') && sed -i "s/maven_local_repo/$maven_repo_replace_str/g" $maven_home/conf/settings.xml

ARG default_maven_repo_home=.m2
ARG default_maven_repo_path=${default_maven_repo_home}/repository

### vscode maven plugin will use default user ~/.m2 path as repo home
### https://github.com/microsoft/vscode-maven/issues/46#issuecomment-500271983
RUN cd ~ && rm -rf ${default_maven_repo_path} && mkdir -p ${maven_repo} && mkdir -p ${default_maven_repo_home} && ln -s ${maven_repo} ${default_maven_repo_path}
RUN cd ~ && rm -f ${default_maven_repo_home}/settings.xml && ln -s ${maven_home}/conf/settings.xml ${default_maven_repo_home}/settings.xml

## gradle
ARG gradle_version=7.0.2
ARG gradle_download_url=https://downloads.gradle-dn.com/distributions/gradle-$gradle_version-bin.zip
ARG gradle_pkg=gradle-${gradle_version}-bin.zip

RUN cd ${java_home} && source /etc/profile && curl -L ${gradle_download_url} -o ${gradle_pkg} && \
    unzip ${gradle_pkg} && rm -f ${gradle_pkg}

## profile
RUN . /tmp/env_java.sh && echo -e '\n# java' >> /etc/profile && \
    echo "export JAVA_HOME=$java_home/$jdk_8_folder" >> /etc/profile && \
    echo 'export JRE_HOME=$JAVA_HOME/jre' >> /etc/profile && \
    echo 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib' >> /etc/profile  && \
    echo "export MAVEN_HOME=$maven_home" >> /etc/profile  && \
    echo "export GRADLE_HOME=/usr/java/gradle-$gradle_version" >> /etc/profile  && \
    echo "export GRADLE_USER_HOME=$java_repo_home/gradle" >> /etc/profile  && \
    echo "export JDK_HOME=$java_home/$jdk_11_folder" >> /etc/profile  && \
    echo 'export PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin:$MAVEN_HOME/bin:$GRADLE_HOME/bin' >> /etc/profile

RUN rm -f /tmp/env_java.sh