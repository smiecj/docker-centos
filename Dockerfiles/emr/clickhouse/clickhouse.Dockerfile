# clickhouse image
# refer: https://github.com/smiecj/AmbariStack/blob/master/CLICKHOUSE/package/scripts/clickhouse.sh
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

# arg: rpm, tag
ARG clickhouse_version=21.7.8
ARG clickhouse_repo=https://repo.yandex.ru/clickhouse/rpm/stable/x86_64
ARG clickhouse_script_home=/opt/modules/clickhouse/scripts
ARG default_password=test_clickhouse_123

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

# install
RUN yum -y install expect && \
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
    rm -f /etc/clickhouse-server/users.d/default-password.xml

## copy config
COPY ./conf/* /etc/clickhouse-server/
COPY ./scripts/init-clickhouse.sh ${clickhouse_script_home}/

## copy start and stop script
COPY ./scripts/clickhouse-restart.sh /usr/local/bin/clickhouserestart
COPY ./scripts/clickhouse-start.sh /usr/local/bin/clickhousestart
COPY ./scripts/clickhouse-stop.sh /usr/local/bin/clickhousestop
RUN chmod +x /usr/local/bin/clickhousestart && chmod +x /usr/local/bin/clickhousestop && chmod +x /usr/local/bin/clickhouserestart

## init service
RUN echo "sh ${clickhouse_script_home}/init-clickhouse.sh && clickhousestart" >> /init_service