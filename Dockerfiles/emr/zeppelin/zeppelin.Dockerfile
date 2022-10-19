ARG DEV_FULL_IMAGE
FROM ${DEV_FULL_IMAGE}

ARG zeppelin_module_home=/opt/modules/zeppelin
ARG zeppelin_version=0.10.1
ARG zeppelin_scripts_home=${zeppelin_module_home}/scripts

ARG apache_repo=https://mirrors.tuna.tsinghua.edu.cn/apache
# ARG apache_repo=https://dlcdn.apache.org

## env
ENV PORT=8080

## install
RUN mkdir -p ${zeppelin_module_home} && cd ${zeppelin_module_home} && \
    zeppelin_folder=zeppelin-${zeppelin_version}-bin-all && \
    zeppelin_pkg=${zeppelin_folder}.tgz && \
    zeppelin_pkg_url=${apache_repo}/zeppelin/zeppelin-${zeppelin_version}/${zeppelin_pkg} && \
    wget ${zeppelin_pkg_url} && tar -xzvf ${zeppelin_pkg} && rm ${zeppelin_pkg} && \
    mv ${zeppelin_folder}/* ./ && rm -rf ${zeppelin_folder}

# copy scripts & config
COPY ./conf/zeppelin-site.xml.template ${zeppelin_module_home}/conf/
RUN mkdir -p ${zeppelin_scripts_home}
COPY ./scripts/init-zeppelin.sh ${zeppelin_scripts_home}
RUN sed -i "s#{zeppelin_module_home}#${zeppelin_module_home}#g" ${zeppelin_scripts_home}/init-zeppelin.sh

COPY ./scripts/zeppelin-start.sh /usr/local/bin/zeppelinstart
COPY ./scripts/zeppelin-stop.sh /usr/local/bin/zeppelinstop
COPY ./scripts/zeppelin-restart.sh /usr/local/bin/zeppelinrestart
RUN sed -i "s#{zeppelin_module_home}#${zeppelin_module_home}#g" /usr/local/bin/zeppelinstart && \
    sed -i "s#{zeppelin_module_home}#${zeppelin_module_home}#g" /usr/local/bin/zeppelinstop && \
    chmod +x /usr/local/bin/zeppelinstart && chmod +x /usr/local/bin/zeppelinstop && chmod +x /usr/local/bin/zeppelinrestart

# init 
RUN echo "sh ${zeppelin_scripts_home}/init-zeppelin.sh && zeppelinstart" >> /init_service