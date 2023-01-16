ARG IMAGE_MINIMAL
FROM ${IMAGE_MINIMAL}

ENV PORT=5432
ENV POSTGRES_PASSWORD=root_Test1qaz
ENV DATA_DIR=/opt/data/pgsql
ENV pgsql_user=postgres

# self define user
ENV USER_DB ""
ENV USER_NAME ""
ENV USER_PASSWORD ""

ARG module_home
ARG pgsql_version
ARG github_url

## copy scripts
COPY ./scripts/init-pgsql.sh /tmp
COPY ./scripts/pgsql-start.sh /usr/local/bin/pgsqlstart
COPY ./scripts/pgsql-stop.sh /usr/local/bin/pgsqlstop
COPY ./scripts/pgsql-restart.sh /usr/local/bin/pgsqlrestart
COPY ./scripts/pgsql-connect.sh /usr/local/bin/pgsqlconnect

RUN pgsql_home=/usr/local/pgsql && \
    pgsql_module_home=${module_home}/pgsql && \
    pgsql_scripts_path=${pgsql_module_home}/scripts && \
    mkdir -p ${pgsql_scripts_path} && \
    mv /tmp/init-pgsql.sh ${pgsql_scripts_path}/ && \

# compile pgsql
    cd /tmp && git clone ${github_url}/postgres/postgres -b REL_${pgsql_version}_STABLE && \ 
    yum -y install gcc readline-devel bison flex zlib-devel && \
    cd postgres && ./configure --prefix=${pgsql_home} && make && make install && \
    echo "# postgresql" >> /etc/profile && \
    echo "export PG_HOME=${pgsql_home}" >> /etc/profile && \
    echo 'export PATH=$PATH:$PG_HOME/bin' >> /etc/profile && \
    cd .. && rm -r postgres && \
    useradd ${pgsql_user} && \

    chmod +x /usr/local/bin/pgsqlstart && chmod +x /usr/local/bin/pgsqlstop && chmod +x /usr/local/bin/pgsqlrestart && \
    chmod +x /usr/local/bin/pgsqlconnect && \

## init
    echo "sh ${pgsql_scripts_path}/init-pgsql.sh > /tmp/init-pgsql.log 2>&1 && pgsqlstart" >> /init_service
