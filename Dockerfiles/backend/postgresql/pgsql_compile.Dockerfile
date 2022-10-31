ARG MINIMAL_IMAGE
FROM ${MINIMAL_IMAGE}

ENV PORT=5432
ENV POSTGRES_PASSWORD=root_Test1qaz
ENV DATA_DIR=/opt/data/pgsql
ENV pgsql_user=postgres

# self define user
ENV USER_DB ""
ENV USER_NAME ""
ENV USER_PASSWORD ""

ARG pgsql_scripts_path=/opt/modules/pgsql/scripts
ARG pgsql_version=14
ARG pgsql_home=/usr/local/pgsql
ARG github_url=https://github.com

RUN mkdir -p ${pgsql_scripts_path}
COPY ./scripts/init-pgsql.sh ${pgsql_scripts_path}/

# compile pgsql
RUN cd /tmp && git clone ${github_url}/postgres/postgres -b REL_${pgsql_version}_STABLE && \ 
    yum -y install gcc readline-devel bison flex zlib-devel && \
    cd postgres && ./configure --prefix=${pgsql_home} && make && make install && \
    echo "# postgresql" >> /etc/profile && \
    echo "export PG_HOME=${pgsql_home}" >> /etc/profile && \
    echo 'export PATH=$PATH:$PG_HOME/bin' >> /etc/profile && \
    cd .. && rm -r postgres && \
    useradd ${pgsql_user}

## copy scripts
COPY ./scripts/pgsql-start.sh /usr/local/bin/pgsqlstart
COPY ./scripts/pgsql-stop.sh /usr/local/bin/pgsqlstop
COPY ./scripts/pgsql-restart.sh /usr/local/bin/pgsqlrestart
RUN chmod +x /usr/local/bin/pgsqlstart && chmod +x /usr/local/bin/pgsqlstop && chmod +x /usr/local/bin/pgsqlrestart

COPY ./scripts/pgsql-connect.sh /usr/local/bin/pgsqlconnect
RUN chmod +x /usr/local/bin/pgsqlconnect

## init
RUN echo "sh ${pgsql_scripts_path}/init-pgsql.sh > /tmp/init-pgsql.log 2>&1 && pgsqlstart" >> /init_service
