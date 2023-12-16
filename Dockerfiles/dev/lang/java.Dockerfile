ARG IMAGE_BASE
FROM ${IMAGE_BASE} AS base

USER root

# install java

## args
ARG java_home=/usr/java
ARG repo_home
ARG java_repo_home=${repo_home}/java
ARG jdk_repo
ARG apache_repo

ARG JDK_OLD_VERSION
ARG JDK_NEW_VERSION

# init repo
COPY ./scripts/init_java_repo /

ARG TARGETARCH
RUN mkdir -p ${java_home} && mkdir -p ${java_repo_home} && \
    if [ "amd64" == "${TARGETARCH}" ]; then arch="x64"; else arch="aarch64"; fi && \
    jdk_new_version_repo="${jdk_repo}/${JDK_NEW_VERSION}/jdk/${arch}/linux" && \
    jdk_new_version_pkg=`curl -L ${jdk_new_version_repo} | grep OpenJDK${JDK_NEW_VERSION}U | grep hotspot | sed 's/.*title="//g' | sed 's/".*//g'` && \
    jdk_new_version_download_url=${jdk_new_version_repo}/${jdk_new_version_pkg} && \
    jdk_new_version_detail_version=`echo ${jdk_new_version_pkg} | sed "s/.*hotspot_${JDK_NEW_VERSION}/${JDK_NEW_VERSION}/g" | sed 's/.tar.*//g' | tr '_' '+'` && \
    jdk_new_version_folder="jdk-${jdk_new_version_detail_version}" && \
    jdk_old_version_repo="${jdk_repo}/8/jdk/${arch}/linux" && \
    jdk_old_version_pkg=`curl -L ${jdk_old_version_repo} | grep OpenJDK${JDK_OLD_VERSION}U | grep hotspot | sed 's/.*title="//g' | sed 's/".*//g'` && \
    jdk_old_version_download_url=${jdk_old_version_repo}/${jdk_old_version_pkg} && \
    jdk_old_version_detail_version=`echo ${jdk_old_version_pkg} | sed "s/.*hotspot_${JDK_OLD_VERSION}/${JDK_OLD_VERSION}/g" | sed 's/.tar.*//g' | sed 's/b/-b/g'` && \
    jdk_old_version_folder="jdk${jdk_old_version_detail_version}" && \
    cd ${java_home} && curl -LO ${jdk_new_version_download_url} && tar -xzvf ${jdk_new_version_pkg} && rm ${jdk_new_version_pkg} && \
    curl -LO ${jdk_old_version_download_url} && tar -xzvf ${jdk_old_version_pkg} && rm ${jdk_old_version_pkg} && \

    echo -e '\n# java' >> /etc/profile && \
    echo "export JAVA_HOME=${java_home}/${jdk_old_version_folder}" >> /etc/profile && \
    echo 'export JRE_HOME=$JAVA_HOME/jre' >> /etc/profile && \
    echo 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib' >> /etc/profile  && \
    echo "export JDK_HOME=${java_home}/${jdk_new_version_folder}" >> /etc/profile

## maven
ARG MAVEN_VERSION
COPY ./maven/settings.xml /tmp/
RUN maven_home=${java_home}/maven && \
    maven_repo=${java_repo_home}/maven && \
    maven_large_version=`echo "${MAVEN_VERSION}" | sed 's#\..*##g'` && \
    maven_actual_version=`curl -L ${apache_repo}/maven/maven-${maven_large_version}/ | grep "${MAVEN_VERSION}" | sed 's/.*href="//g' | sed 's#/.*##g' | sed "s#.*>##g" | tail -1` && \
    maven_folder=apache-maven-${maven_actual_version} && \
    maven_pkg=apache-maven-${maven_actual_version}-bin.tar.gz && \
    maven_download_url=${apache_repo}/maven/maven-${maven_large_version}/${maven_actual_version}/binaries/${maven_pkg} && \
    cd ${java_home} && source /etc/profile && curl -L ${maven_download_url} -o ${maven_pkg} && \
    tar -xzvf ${maven_pkg} && \
    mkdir -p ${maven_home} && \
    mv ${maven_folder}/* ${maven_home}/ && \
    rm ${maven_pkg} && \
    rm -r ${maven_folder} && \
    maven_local_repo=${java_repo_home}/maven && \
    maven_setting=${maven_home}/conf/settings.xml && \
    cp /tmp/settings.xml ${maven_setting} && \
    sed -i "s#{maven_local_repo}#${maven_local_repo}#g" ${maven_setting} && \

    default_maven_repo_home=.m2 && \
    default_maven_repo_path=${default_maven_repo_home}/repository && \

### vscode maven plugin will use default user ~/.m2 path as repo home
### https://github.com/microsoft/vscode-maven/issues/46#issuecomment-500271983
    cd ~ && rm -rf ${default_maven_repo_path} && mkdir -p ${maven_repo} && mkdir -p ${default_maven_repo_home} && ln -s ${maven_repo} ${default_maven_repo_path} && \
    cd ~ && rm -f ${default_maven_repo_home}/settings.xml && ln -s ${maven_setting} ${default_maven_repo_home}/settings.xml && \
    echo "export MAVEN_HOME=${maven_home}" >> /etc/profile


## gradle
ARG GRADLE_VERSION
ARG gradle_repo
RUN gradle_pkg=gradle-${GRADLE_VERSION}-bin.zip && \
    gradle_download_url=${gradle_repo}/${gradle_pkg} && \
    cd ${java_home} && source /etc/profile && curl -L ${gradle_download_url} -o ${gradle_pkg} && \
    unzip ${gradle_pkg} && rm -f ${gradle_pkg}

## ant
ARG ANT_SHORT_VERSION
RUN ant_repo=${apache_repo}/ant/binaries && \
    ant_pkg=`curl -L ${ant_repo}/ | grep apache-ant-${ANT_SHORT_VERSION} | grep "tar.gz" | sed 's#.*href="##g' | sed 's#".*##g' | sed -n 1p` && \
    ant_version=`echo ${ant_pkg} | sed 's#apache-ant-##g' | sed 's#-.*##g'` && \
    ant_folder=apache-ant-${ant_version} && \
    cd /usr/java && curl -LO ${ant_repo}/${ant_pkg} && \
    tar -xzvf ${ant_pkg} && rm ${ant_pkg} && \

## profile
    echo "export GRADLE_HOME=/usr/java/gradle-$GRADLE_VERSION" >> /etc/profile  && \
    echo "export GRADLE_USER_HOME=$java_repo_home/gradle" >> /etc/profile  && \
    echo "export ANT_HOME=$java_home/$ant_folder" >> /etc/profile  && \
    echo 'export PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin:$MAVEN_HOME/bin:$GRADLE_HOME/bin:$ANT_HOME/bin' >> /etc/profile