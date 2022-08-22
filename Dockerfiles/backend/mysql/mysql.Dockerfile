ARG MINIMAL_IMAGE
FROM ${MINIMAL_IMAGE}

# ENV PORT=3306
ENV ROOT_PASSWORD=root_Test1qaz
ENV USER_DB=
ENV DATA_DIR=/var/lib/mysql
ARG mysql_scripts_path=/opt/modules/mysql/scripts
ARG mysql_init_sql_home=/opt/modules/mysql/init_sql

ARG mysql_short_version="8.0"
ARG mysql_version="8.0.27-1"
ARG system_version="el7"

ENV MYSQL_LOG=/var/log/mysqld.log
ENV MYSQL_PID=/var/run/mysqld/mysqld.pid

# ARG mysql_repo_url="https://cdn.mysql.com/Downloads"
ARG mysql_repo_url="https://mirrors.tuna.tsinghua.edu.cn/mysql/downloads"

RUN mkdir -p ${mysql_scripts_path} && mkdir -p ${mysql_init_sql_home}
COPY ./scripts/init-mysql.sh ${mysql_scripts_path}/
RUN sed -i "s#{mysql_init_sql_home}#${mysql_init_sql_home}#g" ${mysql_scripts_path}/init-mysql.sh

# install mysql
## remove installed mysql and mariadb repo
RUN rpm -qa | grep mysql | xargs -I {} rpm -e --nodeps {}
RUN rpm -qa | grep mariadb | xargs -I {} rpm -e --nodeps {}

## basic lib
RUN yum -y install compat-openssl10 libncurses* ncurses libaio numactl

## download rpm and install
ARG TARGETARCH
RUN cd /tmp && if [ "arm64" == "$TARGETARCH" ]; \
then\
    arch="aarch64";\
else\
    arch="x86_64";\
fi && \
mysql_server_rpm_name="mysql-server.rpm" && \
mysql_common_rpm_name="mysql-common.rpm" && \
mysql_client_rpm_name="mysql-client.rpm" && \
mysql_client_plugins_rpm_name="mysql-client-plugins.rpm" && \
mysql_libs_rpm_name="mysql-libs.rpm" && \
mysql_server_rpm_download_link="$mysql_repo_url/MySQL-$mysql_short_version/mysql-community-server-${mysql_version}.$system_version.${arch}.rpm" && \
mysql_common_rpm_download_link="$mysql_repo_url/MySQL-$mysql_short_version/mysql-community-common-${mysql_version}.$system_version.${arch}.rpm" && \
mysql_client_rpm_download_link="$mysql_repo_url/MySQL-$mysql_short_version/mysql-community-client-${mysql_version}.$system_version.${arch}.rpm" && \
mysql_client_plugins_rpm_download_link="$mysql_repo_url/MySQL-$mysql_short_version/mysql-community-client-plugins-${mysql_version}.$system_version.${arch}.rpm" && \
mysql_libs_rpm_download_link="$mysql_repo_url/MySQL-$mysql_short_version/mysql-community-libs-${mysql_version}.$system_version.${arch}.rpm" && \
curl -Lo $mysql_server_rpm_name $mysql_server_rpm_download_link && \
curl -Lo $mysql_common_rpm_name $mysql_common_rpm_download_link && \
curl -Lo $mysql_client_rpm_name $mysql_client_rpm_download_link && \
curl -Lo $mysql_client_plugins_rpm_name $mysql_client_plugins_rpm_download_link && \
curl -Lo $mysql_libs_rpm_name $mysql_libs_rpm_download_link && \
rpm -ivh $mysql_client_plugins_rpm_name && \
rpm -ivh $mysql_common_rpm_name && \
rpm -ivh $mysql_libs_rpm_name && \
rpm -ivh $mysql_client_rpm_name && \
rpm -ivh $mysql_server_rpm_name && \
rm *.rpm

# copy cnf template file
COPY ./config/my.cnf_template /etc/

## s6
COPY s6/ /etc/

## copy mysql password reset and connect script
COPY ./scripts/mysql-connect.sh /usr/local/bin/mysqlconnect
RUN chmod +x /usr/local/bin/mysqlconnect

## init
RUN echo "sh ${mysql_scripts_path}/init-mysql.sh" >> /init_service
