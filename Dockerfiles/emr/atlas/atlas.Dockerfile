ARG IMAGE_ATLAS_BASE
FROM ${IMAGE_ATLAS_BASE}

ARG module_home
ARG atlas_version
ARG apache_repo
ARG github_url

## env
ENV PORT=21000

# scripts
COPY ./scripts/init-atlas.sh /tmp
COPY ./conf/atlas-application.properties_template /tmp
COPY ./scripts/atlas-start.sh /usr/local/bin/atlasstart
COPY ./scripts/atlas-stop.sh /usr/local/bin/atlasstop
COPY ./scripts/atlas-restart.sh /usr/local/bin/atlasrestart

RUN atlas_module_home=${module_home}/atlas && \
    atlas_scripts_home=${atlas_module_home}/scripts && \
    yum -y install python2 && \
## compile atlas
    atlas_source_pkg=apache-atlas-${atlas_version}-sources.tar.gz && \
    atlas_source_folder=apache-atlas-sources-${atlas_version} && \
    atlas_source_url=${apache_repo}/atlas/${atlas_version}/${atlas_source_pkg} && \
    atlas_folder=apache-atlas-${atlas_version} && \
    atlas_pkg=${atlas_folder}-bin.tar.gz && \
    mkdir -p ${atlas_module_home} && cd ${atlas_module_home} && curl -LO ${atlas_source_url} && \
    tar -xzvf ${atlas_source_pkg} && rm ${atlas_source_pkg} && \
    cd ${atlas_source_folder} && source /etc/profile && \
    ## ignore test-tools install
    # sed -i "s#.*test-tools.*##g" pom.xml && \
    ## PKIX path validation failed: ignore ssl check
    ## https://stackoverflow.com/a/68201055
    echo "[test] ready to compile" && \
    mvn clean -DskipTests package -Pdist,embedded-hbase-solr -Drat.skip=true -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true -Dmaven.wagon.http.ssl.ignore.validity.dates=true && \
    echo "[test] compile finish" && \
    cp ./distro/target/${atlas_pkg} ${atlas_module_home} && \
    cd ${atlas_module_home} && tar -xzvf ${atlas_pkg} && rm ${atlas_pkg} && \
    mv ${atlas_folder}/* ./ && rm -r ${atlas_folder} && \
    echo "[test] copy package finish" && \
    rm -r ${atlas_source_folder} && \
    rm -rf ~/.m2/repository/* && \
    echo "[test] 111" && \

# copy scripts
    mkdir -p ${atlas_scripts_home} && \

    echo "[test] 222" && \
    mv /tmp/init-atlas.sh ${atlas_scripts_home} && \
    mv /tmp/atlas-application.properties_template ${atlas_module_home}/conf/ && \
    sed -i "s#{atlas_module_home}#${atlas_module_home}#g" ${atlas_scripts_home}/init-atlas.sh && \
    echo "[test] 333" && \

    sed -i "s#{atlas_module_home}#${atlas_module_home}#g" /usr/local/bin/atlasstart && \
    chmod +x /usr/local/bin/atlasstart && chmod +x /usr/local/bin/atlasstop && chmod +x /usr/local/bin/atlasrestart && \
    echo "[test] 444" && \
# init
    echo "sh ${atlas_scripts_home}/init-atlas.sh && atlasstart" >> /init_service
