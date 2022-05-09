FROM centos_minimal

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
COPY ./scripts/mysql-reset-password.sh /usr/local/bin/mysqlresetpassword
RUN chmod +x /usr/local/bin/mysqlresetpassword
COPY ./scripts/mysql-connect.sh /usr/local/bin/mysqlconnect
RUN chmod +x /usr/local/bin/mysqlconnect

## remove mysql rpm
RUN cd /tmp && rm mysql-*.rpm && rm env_*.sh
