FROM centos_druid_base

# install druid
ARG druid_tag="0.22.1"
ARG druid_module_home=/home/modules/druid
ARG druid_code_pkg_url=https://github.com/apache/druid/archive/refs/tags/druid-${druid_tag}.tar.gz
ARG druid_code_pkg=druid-${druid_tag}.tar.gz
ARG druid_bin_pkg_download_url=https://dlcdn.apache.org/druid/${druid_tag}/apache-druid-${druid_tag}-bin.tar.gz
ARG druid_code_folder=druid-druid-${druid_tag}
ARG druid_code_home=${druid_module_home}/${druid_code_folder}
ARG druid_pkg=apache-druid-${druid_tag}-bin.tar.gz
ARG druid_pkg_folder=apache-druid-${druid_tag}
ARG druid_log=${druid_module_home}/druid_server.log

## python basic pkg
RUN pip3 install pyyaml

## download source code
RUN mkdir -p ${druid_module_home} && cd ${druid_module_home} && \
    curl -LO ${druid_code_pkg_url} && tar -xzvf ${druid_code_pkg} && \
    rm -f ${druid_code_pkg}

## compile
### bug fix: https://github.com/apache/druid/issues/12274
RUN sed -i 's/yaml.load_all(registry_file)/yaml.load_all(registry_file, Loader=yaml.FullLoader)/g' ${druid_code_home}/distribution/bin/generate-binary-license.py
RUN sed -i 's/yaml.load_all(registry_file)/yaml.load_all(registry_file, Loader=yaml.FullLoader)/g' ${druid_code_home}/distribution/bin/generate-binary-notice.py

RUN cd ${druid_code_home} && source /etc/profile && mvn clean install -Pdist,rat -DskipTests

RUN cd ${druid_code_home} && mv ./distribution/target/${druid_pkg} ${druid_module_home} && \
    rm -rf ${druid_code_home} && cd ${druid_module_home} && tar -xzvf ${druid_pkg} && \
    mv ${druid_pkg_folder}/* ./ && rm -f ${druid_pkg}

## copy start and stop script
COPY ./scripts/druid-restart.sh /usr/local/bin/druidrestart
COPY ./scripts/druid-start.sh /usr/local/bin/druidstart
COPY ./scripts/druid-stop.sh /usr/local/bin/druidstop
RUN sed -i "s#{druid_module_home}#${druid_module_home}#g" /usr/local/bin/druidstart && \
    sed -i "s#{druid_log}#${druid_log}#g" /usr/local/bin/druidstart && \
    sed -i "s#{druid_module_home}#${druid_module_home}#g" /usr/local/bin/druidstop
RUN chmod +x /usr/local/bin/druidstart && /usr/local/bin/druidstop && /usr/local/bin/druidrestart

## init service
RUN echo "druidstart" >> /init_service

## todo: 结合 kafka 完成基本测试用例的部署和验证