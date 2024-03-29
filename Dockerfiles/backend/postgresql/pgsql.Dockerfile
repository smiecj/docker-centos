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
ARG TARGETARCH

## copy scripts
COPY ./scripts/pgsql-start.sh /usr/local/bin/pgsqlstart
COPY ./scripts/pgsql-stop.sh /usr/local/bin/pgsqlstop
COPY ./scripts/pgsql-restart.sh /usr/local/bin/pgsqlrestart
COPY ./scripts/pgsql-connect.sh /usr/local/bin/pgsqlconnect
COPY ./scripts/init-pgsql.sh /tmp/

RUN pgsql_module_home=${module_home}/pgsql && \
    pgsql_scripts_path=${pgsql_module_home}/scripts && \
    mkdir -p ${pgsql_scripts_path} && \
    mv /tmp/init-pgsql.sh ${pgsql_scripts_path}/ && \

# install pgsql
## download rpm and install
cd /tmp && if [ "arm64" == "$TARGETARCH" ]; \
then\
    arch="aarch64";\
else\
    arch="x86_64";\
fi && \
centos_version=`cat /etc/centos-release | sed 's#.* ##g' | sed 's#\..*##g'` && \
yum -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-${centos_version}-${arch}/pgdg-redhat-repo-latest.noarch.rpm && \
## disable gpg check
### https://serverfault.com/questions/1095013/how-to-get-redhat-centos-to-run-nogpgcheck-automatically-on-any-call-to-yum-inst
sed -i 's/gpgcheck=1/gpgcheck=0/g' /etc/yum.repos.d/pgdg-redhat-all.repo && \
sed -i 's/repo_gpgcheck = 1/repo_gpgcheck = 0/g' /etc/yum.repos.d/pgdg-redhat-all.repo && \
yum -qy module disable postgresql && \
yum -y install postgresql${pgsql_version}-server && \
pgsql_home=/usr/pgsql-${pgsql_version} && \
echo "# postgresql" >> /etc/profile && \
echo "export PG_HOME=${pgsql_home}" >> /etc/profile && \
echo 'export PATH=$PATH:$PG_HOME/bin' >> /etc/profile && \

chmod +x /usr/local/bin/pgsqlstart && chmod +x /usr/local/bin/pgsqlstop && chmod +x /usr/local/bin/pgsqlrestart && \
chmod +x /usr/local/bin/pgsqlconnect && \

## init
echo "sh ${pgsql_scripts_path}/init-pgsql.sh > /tmp/init-pgsql.log 2>&1 && pgsqlstart" >> /init_service
