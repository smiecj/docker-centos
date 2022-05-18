FROM centos_minimal

# ENV PORT=3306
ENV ROOT_PASSWORD=root_Test1qaz
ENV USER_DB=
ARG mysql_scripts_path=/home/modules/mysql/scripts
ARG mysql_init_sql_home=/home/modules/mysql/init_sql

RUN mkdir -p ${mysql_scripts_path} && mkdir -p ${mysql_init_sql_home}
COPY ./scripts/init-mysql.sh ${mysql_scripts_path}/
RUN sed -i "s#{mysql_init_sql_home}#${mysql_init_sql_home}#g" ${mysql_scripts_path}/init-mysql.sh

## install mysql
COPY ./env_mysql.sh /tmp/
RUN cd /tmp && . ./env_mysql.sh && \
    curl -Lo $mysql_server_rpm_name $mysql_server_rpm_download_link && \
    curl -Lo $mysql_common_rpm_name $mysql_common_rpm_download_link && \
    curl -Lo $mysql_client_rpm_name $mysql_client_rpm_download_link && \
    curl -Lo $mysql_client_plugins_rpm_name $mysql_client_plugins_rpm_download_link && \
    curl -Lo $mysql_libs_rpm_name $mysql_libs_rpm_download_link

### remove installed mysql and mariadb repo
RUN rpm -qa | grep mysql | xargs -I {} rpm -e --nodeps {}
RUN rpm -qa | grep mariadb | xargs -I {} rpm -e --nodeps {}

### basic lib
RUN yum -y install compat-openssl10 libncurses* ncurses libaio numactl

### install downloaded rpm
RUN cd /tmp && . ./env_mysql.sh && \
    rpm -ivh $mysql_client_plugins_rpm_name && \
    rpm -ivh $mysql_common_rpm_name && \
    rpm -ivh $mysql_libs_rpm_name && \
    rpm -ivh $mysql_client_rpm_name && \
    rpm -ivh $mysql_server_rpm_name

## init mysql data dir
# RUN mysqld --initialize
RUN /usr/bin/mysqld_pre_systemd

## s6
COPY s6/ /etc/

## copy mysql password reset and connect script
COPY ./scripts/mysql-connect.sh /usr/local/bin/mysqlconnect
RUN chmod +x /usr/local/bin/mysqlconnect

## remove mysql rpm
RUN cd /tmp && rm mysql-*.rpm && rm env_*.sh

## init
RUN echo "sh ${mysql_scripts_path}/init-mysql.sh" >> /init_service