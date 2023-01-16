ARG MINIMAL_IMAGE
FROM ${MINIMAL_IMAGE}

USER root

# install java (minimal)

## args
ARG java_home=/usr/java
ARG repo_home
ARG java_repo_home=${repo_home}/java

ARG jdk_old_version=8
ARG jdk_repo

ARG TARGETARCH
RUN mkdir -p ${java_home} && mkdir -p ${java_repo_home} && \
    if [ "amd64" == "${TARGETARCH}" ]; then arch="x64"; else arch="aarch64"; fi && \

    jdk_old_version_repo="${jdk_repo}/8/jdk/${arch}/linux" && \
    jdk_old_version_pkg=`curl -L ${jdk_old_version_repo} | grep OpenJDK${jdk_old_version}U | grep hotspot | sed 's/.*title="//g' | sed 's/".*//g'` && \
    jdk_old_version_download_url=${jdk_old_version_repo}/${jdk_old_version_pkg} && \
    jdk_old_version_detail_version=`echo ${jdk_old_version_pkg} | sed "s/.*hotspot_${jdk_old_version}/${jdk_old_version}/g" | sed 's/.tar.*//g' | sed 's/b/-b/g'` && \
    jdk_old_version_folder="jdk${jdk_old_version_detail_version}" && \
    curl -LO ${jdk_old_version_download_url} && tar -xzvf ${jdk_old_version_pkg} && rm ${jdk_old_version_pkg} && \

    echo -e '\n# java' >> /etc/profile && \
    echo "export JAVA_HOME=${java_home}/${jdk_old_version_folder}" >> /etc/profile && \
    echo 'export JRE_HOME=$JAVA_HOME/jre' >> /etc/profile && \
    echo 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib' >> /etc/profile