ARG IMAGE_DEV_FULL
FROM ${IMAGE_DEV_FULL}

ARG module_home
ARG zeppelin_version
ARG apache_repo

## env
ENV PORT=8080

# scripts
COPY ./conf/zeppelin-site.xml.template /tmp
COPY ./scripts/init-zeppelin.sh /tmp
COPY ./scripts/zeppelin-start.sh /usr/local/bin/zeppelinstart
COPY ./scripts/zeppelin-stop.sh /usr/local/bin/zeppelinstop
COPY ./scripts/zeppelin-restart.sh /usr/local/bin/zeppelinrestart

## install
RUN zeppelin_module_home=${module_home}/zeppelin && \
    zeppelin_scripts_home=${zeppelin_module_home}/scripts && \
    mkdir -p ${zeppelin_module_home} && cd ${zeppelin_module_home} && \
    zeppelin_folder=zeppelin-${zeppelin_version}-bin-all && \
    zeppelin_pkg=${zeppelin_folder}.tgz && \
    zeppelin_pkg_url=${apache_repo}/zeppelin/zeppelin-${zeppelin_version}/${zeppelin_pkg} && \
    wget ${zeppelin_pkg_url} && tar -xzvf ${zeppelin_pkg} && rm ${zeppelin_pkg} && \
    mv ${zeppelin_folder}/* ./ && rm -rf ${zeppelin_folder} && \

# copy scripts & config
    mkdir -p ${zeppelin_scripts_home} && \
    mv /tmp/init-zeppelin.sh ${zeppelin_scripts_home} && \
    mv /tmp/zeppelin-site.xml.template ${zeppelin_module_home}/conf/ && \

    sed -i "s#{zeppelin_module_home}#${zeppelin_module_home}#g" ${zeppelin_scripts_home}/init-zeppelin.sh && \

    sed -i "s#{zeppelin_module_home}#${zeppelin_module_home}#g" /usr/local/bin/zeppelinstart && \
    sed -i "s#{zeppelin_module_home}#${zeppelin_module_home}#g" /usr/local/bin/zeppelinstop && \
    chmod +x /usr/local/bin/zeppelinstart && chmod +x /usr/local/bin/zeppelinstop && chmod +x /usr/local/bin/zeppelinrestart && \

# init 
    echo "sh ${zeppelin_scripts_home}/init-zeppelin.sh && zeppelinstart" >> /init_service