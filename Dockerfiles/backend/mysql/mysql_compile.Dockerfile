FROM ${BASE_IMAGE}

ENV PORT=3306
ENV ROOT_PASSWORD=root_Test1qaz
ENV USER_DB=
ENV DATA_DIR=/var/lib/mysql
ARG mysql_scripts_path=/opt/modules/mysql/scripts
ARG mysql_init_sql_home=/opt/modules/mysql/init_sql

RUN mkdir -p ${mysql_scripts_path} && mkdir -p ${mysql_init_sql_home}
COPY ./scripts/init-mysql.sh ${mysql_scripts_path}/
RUN sed -i "s#{mysql_init_sql_home}#${mysql_init_sql_home}#g" ${mysql_scripts_path}/init-mysql.sh

ARG mysql_module_home=/opt/modules/mysql
ARG mysql_version=8.0.29
ARG mysql_short_version=8.0
ARG mysql_source_pkg=mysql-boost-8.0.29.tar.gz
# ARG mysql_download_repo=https://dev.mysql.com/get/Downloads
ARG mysql_download_repo=https://mirrors.tuna.tsinghua.edu.cn/mysql/downloads
ARG mysql_source_pkg_url=${mysql_download_repo}/MySQL-${mysql_short_version}/mysql-boost-${mysql_version}.tar.gz
ARG mysql_source_pkg=mysql-boost-${mysql_version}.tar.gz
ARG mysql_source_folder=mysql-${mysql_version}

ENV MYSQL_LOG=/var/log/mysqld.log
ENV MYSQL_PID=/var/run/mysqld/mysqld.pid

# env init
ARG TARGETARCH
RUN yum -y install libtirpc-devel diffutils ncurses-devel
RUN cd /tmp && if [ "arm64" == "$TARGETARCH" ]; \
then\
    arch="aarch64";\
else\
    arch="x86_64";\
fi && rpcgen_rpm_url=https://vault.centos.org/centos/8/PowerTools/${arch}/os/Packages/rpcgen-1.3.1-4.el8.${arch}.rpm && \
rpcgen_rpm=rpcgen-1.3.1-4.el8.${arch}.rpm && \
curl -LO ${rpcgen_rpm_url} && rpm -ivh ${rpcgen_rpm} && rm ${rpcgen_rpm}

# compile
RUN mkdir -p ${mysql_module_home} && cd ${mysql_module_home} && curl -LO ${mysql_source_pkg_url} && \
    tar -xzvf ${mysql_source_pkg} && rm ${mysql_source_pkg} && cd ${mysql_source_folder} && \
    cmake . -DCMAKE_INSTALL_PREFIX=${mysql_module_home} \
    -DMYSQL_DATADIR=${DATA_DIR} \
    -DWITH_DEBUG=1 \
    -DSYSCONFDIR=${mysql_module_home}/debug \
    -DMYSQL_TCP_PORT=${PORT} \
    -DWITH_BOOST=${mysql_module_home}/boost \
    -DCMAKE_CXX_COMPILER=/usr/bin/g++ \
    -DFORCE_INSOURCE_BUILD=1s \
    -DDOWNLOAD_BOOST=1 \
    -DCURSES_LIBRARY=/usr/lib64/libncurses.so.6 \
    -DCURSES_INCLUDE_PATH=/usr/include/ncurses && \
    make && make install && \
    cd .. && rm -rf ${mysql_source_folder} && rm -rf debug && rm -rf boost

# link mysql to bin path
RUN ln -s ${mysql_module_home}/bin/mysql /usr/sbin/mysql && \
    ln -s ${mysql_module_home}/bin/mysqld /usr/sbin/mysqld && \
    ln -s ${mysql_module_home}/bin/mysqladmin /usr/sbin/mysqladmin

# copy cnf template file
COPY ./config/my.cnf_template /etc/

# s6
COPY s6/ /etc/

# copy mysql password reset and connect script
COPY ./scripts/mysql-connect.sh /usr/local/bin/mysqlconnect
RUN chmod +x /usr/local/bin/mysqlconnect

## init
RUN echo "sh ${mysql_scripts_path}/init-mysql.sh" >> /init_service