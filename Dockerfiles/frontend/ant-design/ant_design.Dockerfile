ARG NODEJS_IMAGE
FROM ${NODEJS_IMAGE}

ARG ant_version=v5.2.0
ARG ant_short_version=5.2.0
ARG ant_code_url=https://github.com/ant-design/ant-design-pro/archive/refs/tags/${ant_version}.tar.gz
ARG ant_code_pkg=${ant_version}.tar.gz
ARG ant_folder=ant-design-pro-${ant_short_version}
ARG ant_code_home=/home/coding
ARG ant_log=${ant_code_home}/${ant_folder}/ant.log

ENV PORT=8000

# download code
RUN mkdir -p ${ant_code_home} && cd ${ant_code_home} && curl -LO ${ant_code_url} && \
    tar -xzvf ${ant_code_pkg} && rm -f ${ant_code_pkg}

# npm install
## fix-Can't resolve 'btoa': https://github.com/ant-design/ant-design-pro/issues/9880
RUN cd ${ant_code_home}/${ant_folder} && source /etc/profile && npm install && npm install btoa

# scripts
COPY ./scripts/ant-start.sh /usr/local/bin/antstart
RUN sed -i "s#{ant_home}#${ant_code_home}/${ant_folder}#g" /usr/local/bin/antstart
RUN sed -i "s#{ant_log}#${ant_log}#g" /usr/local/bin/antstart
RUN chmod +x /usr/local/bin/antstart

COPY ./scripts/ant-restart.sh /usr/local/bin/antrestart
RUN chmod +x /usr/local/bin/antrestart

COPY ./scripts/ant-stop.sh /usr/local/bin/antstop
RUN chmod +x /usr/local/bin/antstop

# init service
RUN echo "antstart" >> /init_service

# log
RUN addlogrotate ${ant_log} ant-design