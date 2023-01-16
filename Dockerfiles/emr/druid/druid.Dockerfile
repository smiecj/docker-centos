ARG IMAGE_DRUID_BASE
FROM ${IMAGE_DRUID_BASE}

# install druid
ARG druid_version
ARG module_home
ARG github_url

# scripts
COPY ./scripts/druid-restart.sh /usr/local/bin/druidrestart
COPY ./scripts/druid-start.sh /usr/local/bin/druidstart
COPY ./scripts/druid-stop.sh /usr/local/bin/druidstop

## python basic pkg
RUN druid_module_home=${module_home}/druid && \
    pip3 install pyyaml && \

## download source code
# ARG druid_bin_pkg_download_url=https://dlcdn.apache.org/druid/${druid_version}/apache-druid-${druid_version}-bin.tar.gz
    druid_code_pkg=druid-${druid_version}.tar.gz && \
    druid_code_pkg_url=${github_url}/apache/druid/archive/refs/tags/druid-${druid_version}.tar.gz && \
    druid_code_folder=druid-druid-${druid_version} && \
    druid_code_home=${druid_module_home}/${druid_code_folder} && \
    druid_pkg=apache-druid-${druid_version}-bin.tar.gz && \
    druid_pkg_folder=apache-druid-${druid_version} && \

    mkdir -p ${druid_module_home} && cd ${druid_module_home} && \
    curl -LO ${druid_code_pkg_url} && tar -xzvf ${druid_code_pkg} && \
    rm -f ${druid_code_pkg} && \

## compile
### bug fix: https://github.com/apache/druid/issues/12274
    sed -i 's/yaml.load_all(registry_file)/yaml.load_all(registry_file, Loader=yaml.FullLoader)/g' ${druid_code_home}/distribution/bin/generate-binary-license.py && \
    sed -i 's/yaml.load_all(registry_file)/yaml.load_all(registry_file, Loader=yaml.FullLoader)/g' ${druid_code_home}/distribution/bin/generate-binary-notice.py && \

    cd ${druid_code_home} && source /etc/profile && mvn clean install -Pdist,rat -DskipTests && \
    mv ./distribution/target/${druid_pkg} ${druid_module_home} && \
    cd ${druid_module_home} && rm -rf ${druid_code_home} && tar -xzvf ${druid_pkg} && \
    mv ${druid_pkg_folder}/* ./ && rm ${druid_pkg} && \
    rm -rf ~/.m2/repository/* && \

## copy start and stop script
    druid_log=${druid_module_home}/druid_server.log && \
    sed -i "s#{druid_module_home}#${druid_module_home}#g" /usr/local/bin/druidstart && \
    sed -i "s#{druid_log}#${druid_log}#g" /usr/local/bin/druidstart && \
    sed -i "s#{druid_module_home}#${druid_module_home}#g" /usr/local/bin/druidstop && \
    chmod +x /usr/local/bin/druidstart && chmod +x /usr/local/bin/druidstop && chmod +x /usr/local/bin/druidrestart && \

## init service
    echo "druidstart" >> /init_service
