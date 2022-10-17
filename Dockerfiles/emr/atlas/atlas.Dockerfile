ARG JAVA_IMAGE
FROM ${JAVA_IMAGE}

ARG modules_home=/opt/modules
ARG atlas_module_home=${modules_home}/atlas
ARG atlas_scripts_home=${atlas_module_home}/scripts

ARG repo_home=/home/repo
ARG java_repo_home=${repo_home}/java

ARG atlas_version=2.2.0

ARG apache_repo=https://dlcdn.apache.org
# ARG apache_repo=https://mirrors.tuna.tsinghua.edu.cn/apache

## env
ENV PORT=21000

RUN yum -y install python2 && ln -s /usr/bin/python2 /usr/bin/python
## install nodejs 15
RUN nodejs_version=v15.14.0 && shell_tool_repo_url=https://github.com/smiecj/shell-tools && \
    shell_tool_branch=branch-v1.0 && \
    cd /tmp && git clone ${shell_tool_repo_url} -b ${shell_tool_branch} && \
    cd shell-tools && make nodejs_version=${nodejs_version} nodejs && \
    cd .. && rm -r shell-tools

## compile atlas
RUN atlas_source_pkg=apache-atlas-${atlas_version}-sources.tar.gz && \
    atlas_source_folder=apache-atlas-sources-${atlas_version} && \
    atlas_source_url=${apache_repo}/atlas/${atlas_version}/${atlas_source_pkg} && \
    atlas_folder=apache-atlas-${atlas_version} && \
    atlas_pkg=${atlas_folder}-bin.tar.gz && \
    mkdir -p ${atlas_module_home} && cd ${atlas_module_home} && curl -LO ${atlas_source_url} && \
    tar -xzvf ${atlas_source_pkg} && rm ${atlas_source_pkg} && \
    cd ${atlas_source_folder} && source /etc/profile && \
    mvn clean -DskipTests package -Pdist,embedded-hbase-solr -Drat.skip=true && \
    cp ./distro/target/${atlas_pkg} ${atlas_module_home} && \
    cd ${atlas_module_home} && tar -xzvf ${atlas_pkg} && rm ${atlas_pkg} && \
    mv ${atlas_folder}/* ./ && rm -r ${atlas_folder} && \
    rm -r ${atlas_source_folder} && \
    rm -r ${java_repo_home}

# copy scripts
RUN mkdir -p ${atlas_scripts_home}
COPY ./scripts/init-atlas.sh ${atlas_scripts_home}
COPY ./conf/atlas-application.properties_template ${atlas_module_home}/conf/
RUN sed -i "s#{atlas_module_home}#${atlas_module_home}#g" ${atlas_scripts_home}/init-atlas.sh

COPY ./scripts/atlas-start.sh /usr/local/bin/atlasstart
COPY ./scripts/atlas-stop.sh /usr/local/bin/atlasstop
COPY ./scripts/atlas-restart.sh /usr/local/bin/atlasrestart

RUN sed -i "s#{atlas_module_home}#${atlas_module_home}#g" /usr/local/bin/atlasstart && \
    chmod +x /usr/local/bin/atlasstart && chmod +x /usr/local/bin/atlasstop && chmod +x /usr/local/bin/atlasrestart

# init
RUN echo "sh ${atlas_scripts_home}/init-atlas.sh && atlasstart" >> /init_service
