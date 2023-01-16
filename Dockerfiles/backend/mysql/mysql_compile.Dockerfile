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

# script and config
COPY ./config/my.cnf_template /etc/
COPY s6/ /etc/
COPY ./scripts/mysql-connect.sh /usr/local/bin/mysqlconnect
COPY ./scripts/init-mysql.sh /tmp

ARG mysql_repo
ARG mysql_version
ARG mysql_short_version
ARG TARGETARCH

ENV MYSQL_LOG=/var/log/mysqld.log
ENV MYSQL_PID=/var/run/mysqld/mysqld.pid

RUN mysql_scripts_path=${module_home}/mysql/scripts && \
mysql_init_sql_home=${module_home}/mysql/init_sql && \
mysql_module_home=${module_home}/mysql && \
mysql_source_pkg=mysql-boost-${mysql_version}.tar.gz && \
mysql_source_pkg=mysql-boost-${mysql_version}.tar.gz && \
mysql_source_folder=mysql-${mysql_version} && \
mkdir -p ${mysql_scripts_path} && mkdir -p ${mysql_init_sql_home} && \

# env init
yum -y install libtirpc-devel diffutils ncurses-devel && \
    cd /tmp && if [ "arm64" == "$TARGETARCH" ]; \
then\
    arch="aarch64";\
else\
    arch="x86_64";\
fi && rpcgen_rpm_url=https://vault.centos.org/centos/8/PowerTools/${arch}/os/Packages/rpcgen-1.3.1-4.el8.${arch}.rpm && \
rpcgen_rpm=rpcgen-1.3.1-4.el8.${arch}.rpm && \
curl -LO ${rpcgen_rpm_url} && rpm -ivh ${rpcgen_rpm} && rm ${rpcgen_rpm} && \

# compile
mysql_source_pkg_url=${mysql_repo}/MySQL-${mysql_short_version}/mysql-boost-${mysql_version}.tar.gz && \
echo "[test] mysql_source_pkg_url: ${mysql_source_pkg_url}" && \
mkdir -p ${mysql_module_home} && cd ${mysql_module_home} && curl -LO ${mysql_source_pkg_url} && \
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
cd .. && rm -rf ${mysql_source_folder} && rm -rf debug && rm -rf boost && \

# link mysql to bin path
ln -s ${mysql_module_home}/bin/mysql /usr/sbin/mysql && \
ln -s ${mysql_module_home}/bin/mysqld /usr/sbin/mysqld && \
ln -s ${mysql_module_home}/bin/mysqladmin /usr/sbin/mysqladmin && \

mv /tmp/init-mysql.sh ${mysql_scripts_path}/ && \
sed -i "s#{mysql_init_sql_home}#${mysql_init_sql_home}#g" ${mysql_scripts_path}/init-mysql.sh && \
chmod +x /usr/local/bin/mysqlconnect && \

## init
echo "sh ${mysql_scripts_path}/init-mysql.sh" >> /init_service