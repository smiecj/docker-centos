ARG IMAGE_MINIMAL
FROM ${IMAGE_MINIMAL}

ENV PORT=3306
ENV ROOT_PASSWORD=root_Test1qaz
ENV DATA_DIR=/var/lib/mysql

# self define user
ENV USER_DB ""
ENV USER_NAME ""
ENV USER_PASSWORD ""

ARG module_home

ARG mysql_repo
ARG mysql_short_version
ARG mysql_release_version
ARG mysql_system_version
ARG TARGETARCH

ENV MYSQL_LOG=/var/log/mysqld.log
ENV MYSQL_PID=/var/run/mysqld/mysqld.pid

# copy cnf template file
COPY ./config/my.cnf_template /etc/

## s6
COPY s6/ /etc/

## copy mysql password reset and connect script
COPY ./scripts/mysql-connect.sh /usr/local/bin/mysqlconnect
COPY ./scripts/init-mysql.sh /tmp

RUN mysql_scripts_path=${module_home}/mysql/scripts && \
mysql_init_sql_home=${module_home}/mysql/init_sql && \
mkdir -p ${mysql_scripts_path} && mkdir -p ${mysql_init_sql_home} && \

# install mysql
## remove installed mysql and mariadb repo
rpm -qa | grep mysql | xargs -I {} rpm -e --nodeps {} && \
rpm -qa | grep mariadb | xargs -I {} rpm -e --nodeps {} && \

## basic lib
yum -y install compat-openssl10 libncurses* ncurses libaio numactl && \

## download rpm and install
cd /tmp && if [ "arm64" == "$TARGETARCH" ]; \
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
mysql_icu_data_files_rpm_name="mysql-community-icu-data-files.rpm" && \
mysql_server_rpm_download_link="${mysql_repo}/MySQL-$mysql_short_version/mysql-community-server-${mysql_release_version}.${mysql_system_version}.${arch}.rpm" && \
mysql_common_rpm_download_link="${mysql_repo}/MySQL-$mysql_short_version/mysql-community-common-${mysql_release_version}.${mysql_system_version}.${arch}.rpm" && \
mysql_client_rpm_download_link="${mysql_repo}/MySQL-$mysql_short_version/mysql-community-client-${mysql_release_version}.${mysql_system_version}.${arch}.rpm" && \
mysql_client_plugins_rpm_download_link="${mysql_repo}/MySQL-$mysql_short_version/mysql-community-client-plugins-${mysql_release_version}.${mysql_system_version}.${arch}.rpm" && \
mysql_libs_rpm_download_link="${mysql_repo}/MySQL-$mysql_short_version/mysql-community-libs-${mysql_release_version}.${mysql_system_version}.${arch}.rpm" && \
mysql_icu_data_files_rpm_download_link="${mysql_repo}/MySQL-$mysql_short_version/mysql-community-icu-data-files-${mysql_release_version}.${mysql_system_version}.${arch}.rpm" && \
curl -Lo $mysql_server_rpm_name $mysql_server_rpm_download_link && \
curl -Lo $mysql_common_rpm_name $mysql_common_rpm_download_link && \
curl -Lo $mysql_client_rpm_name $mysql_client_rpm_download_link && \
curl -Lo $mysql_client_plugins_rpm_name $mysql_client_plugins_rpm_download_link && \
curl -Lo $mysql_libs_rpm_name $mysql_libs_rpm_download_link && \
curl -Lo $mysql_icu_data_files_rpm_name $mysql_icu_data_files_rpm_download_link && \
rpm -ivh $mysql_client_plugins_rpm_name && \
rpm -ivh $mysql_common_rpm_name && \
rpm -ivh $mysql_libs_rpm_name && \
rpm -ivh $mysql_icu_data_files_rpm_name && \
rpm -ivh $mysql_client_rpm_name && \
rpm -ivh $mysql_server_rpm_name && \
rm *.rpm && \

chmod +x /usr/local/bin/mysqlconnect && \
mv /tmp/init-mysql.sh ${mysql_scripts_path}/ && \
sed -i "s#{mysql_init_sql_home}#${mysql_init_sql_home}#g" ${mysql_scripts_path}/init-mysql.sh && \

## init
echo "sh ${mysql_scripts_path}/init-mysql.sh > /tmp/init-mysql.log 2>&1" >> /init_service
