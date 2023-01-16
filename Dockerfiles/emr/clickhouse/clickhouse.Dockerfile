# clickhouse image
# refer: https://github.com/smiecj/AmbariStack/blob/master/CLICKHOUSE/package/scripts/clickhouse.sh
ARG IMAGE_BASE
FROM ${IMAGE_BASE}

# arg: rpm, tag
ARG module_home
ARG clickhouse_version
ARG clickhouse_repo

# env: zookeeper
ENV ZOOKEEPER_NODES=localhost:2181

# env: data
ENV DATA_PATH=/opt/data/clickhouse
ENV TMP_PATH=/opt/temp/clickhouse

# env: clickhouse server
ENV CLUSTER_NAME=my_cluster
ENV HTTP_PORT=8123
ENV TCP_PORT=9000
ENV METRICS_PORT=9363
ENV REPLICA_NODES=ck00

# env: user
ENV USER_NAME=testck
ENV USER_PASSWORD=test_CK_123
ENV USER_DEFAULT_DB_PREFIX=ck_test
ENV USER_ALLOW_DB=ck_test00

## copy script
COPY ./scripts/init-clickhouse.sh /tmp
COPY ./scripts/clickhouse-restart.sh /usr/local/bin/clickhouserestart
COPY ./scripts/clickhouse-start.sh /usr/local/bin/clickhousestart
COPY ./scripts/clickhouse-stop.sh /usr/local/bin/clickhousestop

# install
RUN clickhouse_script_home=${module_home}/clickhouse/scripts && \
    default_password=test_clickhouse_123 && \
    yum -y install expect && \
    cd /tmp && \
    clickhouse_server_rpm=`curl -L ${clickhouse_repo} | grep "clickhouse-server-${clickhouse_version}" | sed 's#rpm.*#rpm#g' | sed 's#.*clickhouse#clickhouse#g'` && \
    clickhouse_server_rpm_url=${clickhouse_repo}/${clickhouse_server_rpm} && \
    curl -LO ${clickhouse_server_rpm_url} && \
    clickhouse_client_rpm=`curl -L ${clickhouse_repo} | grep "clickhouse-client-${clickhouse_version}" | sed 's#rpm.*#rpm#g' | sed 's#.*clickhouse#clickhouse#g'` && \
    clickhouse_client_rpm_url=${clickhouse_repo}/${clickhouse_client_rpm} && \
    curl -LO ${clickhouse_client_rpm_url} && \
    clickhouse_common_rpm=`curl -L ${clickhouse_repo} | grep "clickhouse-common-static-${clickhouse_version}" | sed 's#rpm.*#rpm#g' | sed 's#.*clickhouse#clickhouse#g'` && \
    clickhouse_common_rpm_url=${clickhouse_repo}/${clickhouse_common_rpm} && \
    curl -LO ${clickhouse_common_rpm_url} && \
    rpm -ivh $clickhouse_common_rpm && \
    rpm -ivh $clickhouse_client_rpm && \
    expect_password_str="Enter password for default user" && \
    expect -c "spawn rpm -ivh $clickhouse_server_rpm;expect \"$expect_password_str\";send \"${default_password}\n\";interact" && \
    rm /etc/clickhouse-server/users.d/default-password.xml && \
    rm *.rpm && \

    chmod +x /usr/local/bin/clickhousestart && chmod +x /usr/local/bin/clickhousestop && chmod +x /usr/local/bin/clickhouserestart && \

## init service
    mkdir -p ${clickhouse_script_home} && \
    mv /tmp/init-clickhouse.sh ${clickhouse_script_home}/ && \
    echo "sh ${clickhouse_script_home}/init-clickhouse.sh && clickhousestart" >> /init_service

## copy conf template
COPY ./conf/* /etc/clickhouse-server/