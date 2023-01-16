ARG IMAGE_NODEJS
FROM ${IMAGE_NODEJS}

ARG github_url
ARG code_home
ARG ant_design_version

ENV PORT=8000

# scripts
COPY ./scripts/ant-start.sh /usr/local/bin/antstart
COPY ./scripts/ant-restart.sh /usr/local/bin/antrestart
COPY ./scripts/ant-stop.sh /usr/local/bin/antstop

# download code
RUN ant_design_long_version=v${ant_design_version} && \
    ant_design_code_pkg=${ant_design_long_version}.tar.gz && \
    ant_design_code_url=${github_url}/ant-design/ant-design-pro/archive/refs/tags/${ant_design_code_pkg} && \
    ant_design_folder=ant-design-pro-${ant_design_version} && \
    mkdir -p ${code_home} && cd ${code_home} && curl -LO ${ant_design_code_url} && \
    tar -xzvf ${ant_design_code_pkg} && rm ${ant_design_code_pkg} && \
    ant_design_log=${code_home}/${ant_design_folder}/ant.log && \

# npm install
## fix-Can't resolve 'btoa': https://github.com/ant-design/ant-design-pro/issues/9880
    cd ${code_home}/${ant_design_folder} && source /etc/profile && npm install && npm install btoa && \
    sed -i "s#{ant_design_home}#${code_home}/${ant_design_folder}#g" /usr/local/bin/antstart && \
    sed -i "s#{ant_design_log}#${ant_design_log}#g" /usr/local/bin/antstart && \
    chmod +x /usr/local/bin/antstart && \
    chmod +x /usr/local/bin/antrestart && \
    chmod +x /usr/local/bin/antstop && \

# init service
    echo "antstart" >> /init_service && \

# log
    addlogrotate ${ant_design_log} ant-design