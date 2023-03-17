# azkaban single node
ARG IMAGE_JAVA
FROM ${IMAGE_JAVA}

ARG module_home
ARG github_url
ARG apache_repo

ARG dolphinscheduler_version

# scripts
COPY ./scripts/dolphinscheduler-start.sh /usr/local/bin/dolphinschedulerstart
COPY ./scripts/dolphinscheduler-stop.sh /usr/local/bin/dolphinschedulerstop
COPY ./scripts/dolphinscheduler-restart.sh /usr/local/bin/dolphinschedulerrestart

# compile
RUN dolphinscheduler_pkg_folder=apache-dolphinscheduler-${dolphinscheduler_version}-bin && \
    dolphinscheduler_pkg=${dolphinscheduler_pkg_folder}.tar.gz && \
    dolphinscheduler_pkg_url=${apache_repo}/dolphinscheduler/${dolphinscheduler_version}/${dolphinscheduler_pkg} && \
    dolphinscheduler_module_home=${module_home}/dolphinscheduler && \

    mkdir ${module_home} && cd ${module_home} && \
    curl -LO ${dolphinscheduler_pkg_url} && \
    tar -xzvf ${dolphinscheduler_pkg} && \
    mkdir ${dolphinscheduler_module_home} && mv ${dolphinscheduler_pkg_folder}/* ${dolphinscheduler_module_home} && \
    rm -r ${dolphinscheduler_pkg_folder} && rm ${dolphinscheduler_pkg} && \
    
    sed -i "s#{dolphinscheduler_module_home}#${dolphinscheduler_module_home}#g" /usr/local/bin/dolphinschedulerstart && \
    chmod +x /usr/local/bin/dolphinschedulerstart && chmod +x /usr/local/bin/dolphinschedulerstop && chmod +x /usr/local/bin/dolphinschedulerrestart && \
# init 
    echo "dolphinschedulerstart" >> /init_service