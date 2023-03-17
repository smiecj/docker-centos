ARG IMAGE_HUE_BASE
FROM ${IMAGE_HUE_BASE}

# install hue
ARG github_url
ARG maven_repo
ARG hue_branch

## env: mysql
ENV MYSQL_HOST=localhost
ENV MYSQL_PORT=3306
ENV MYSQL_DB=hue
ENV MYSQL_USER=hue
ENV MYSQL_PASSWORD=hue123
ENV HUE_MYSQL_QUERIER_NAME=HueDB

## config: admin user
ENV ADMIN_USER=admin
ENV ADMIN_PASSWORD=admin
ENV ADMIN_MAIL=admin@test.com

## config: hadoop
ENV HIVE_SERVER_HOST=
ENV HIVE_SERVER_PORT=10000

ENV DEFAULTFS=
ENV WEBHDFS_ADDRESS=

## config: presto
ENV PRESTO_SERVER=
ENV PRESTO_HIVE_CATALOG=

## config: server
ENV PORT=8281

## config: hue desktop
ENV TIME_ZONE=Asia/Shanghai

## copy config and scripts
COPY ./cdh-root-6.3.3.pom /tmp
COPY ./scripts/init-hue.sh /tmp
COPY ./scripts/hue-restart.sh /usr/local/bin/huerestart
COPY ./scripts/hue-start.sh /usr/local/bin/huestart
COPY ./scripts/hue-stop.sh /usr/local/bin/huestop
COPY ./scripts/hue-log.sh /usr/local/bin/huelog
COPY ./scripts/hue-syncdb.sh /usr/local/bin/huesyncdb

RUN hue_install_prefix=/usr/local && \
    hue_install_path=${hue_install_prefix}/hue && \
    hue_scripts_home=${hue_install_path}/scripts && \

    mysql_version=8.0.26 && \
    mysql_jdbc_url=${maven_repo}/mysql/mysql-connector-java/${mysql_version}/mysql-connector-java-${mysql_version}.jar && \
    mysql_jdbc_file_name=mysql-connector-java-${mysql_version}.jar && \
    mysql_jdbc_class=com.mysql.cj.jdbc.Driver && \

    hue_code_pkg=${hue_branch}.zip && \
    code_home=/tmp && \
    hue_code_folder=hue-${hue_branch} && \
    hue_code_home=${code_home}/${hue_code_folder} && \
    hue_code_repo=${github_url}/smiecj/hue && \
    hue_code_url=${hue_code_repo}/archive/refs/heads/${hue_branch}.zip && \
    cd ${code_home} && curl -LO ${hue_code_url} && unzip ${hue_code_pkg} && cd ${hue_code_folder} && \
    mv /tmp/cdh-root-6.3.3.pom ${hue_code_home}/maven && \
    sed -i 's/<version>6.3.3<\/version>/<version>6.3.3<\/version>\n<relativePath>.\/cdh-root-6.3.3.pom<\/relativePath>/g' ${hue_code_home}/maven/pom.xml && \

## basic env
    yum -y install make gcc gcc-c++ cmake cyrus-sasl-devel cyrus-sasl-gssapi cyrus-sasl-plain libffi-devel libxml2 libxml2-devel libxslt libxslt-devel mysql mysql-devel openldap-devel sqlite-devel gmp-devel python2-devel && \
### install mysql-connector-c
    cd /tmp && git clone ${github_url}/smiecj/mysql-connector-c && cd mysql-connector-c && cmake . && cp ./include/my_config.h /usr/include/mysql/ && rm -r /tmp/mysql-connector-c && \
### install other python dependency
    cd /tmp && pip2 install cryptography==3.3.2 && \

    cd ${hue_code_home} && source /etc/profile && PREFIX=${hue_install_prefix} make install && \
    rm -rf ${hue_code_home} && \

## hue config
    mkdir -p ${hue_install_path}/build/static/desktop && \
    yes | cp -r ${hue_install_path}/desktop/core/src/desktop/static/desktop/js ${hue_install_path}/build/static/desktop && \

    cd ${hue_install_path}/desktop/conf && mv pseudo-distributed.ini.tmpl hue.ini && cp hue.ini hue.ini_example && \

### soft link
    mkdir -p /etc/hue && ln -s ${hue_install_path}/desktop/conf /etc/hue/conf && \

## hue scripts
    mkdir -p ${hue_scripts_home} && \
    mv /tmp/init-hue.sh ${hue_scripts_home}/ && \
    sed -i "s#{hue_install_path}#${hue_install_path}#g" ${hue_scripts_home}/init-hue.sh && \
    sed -i "s#{mysql_jdbc_class}#${mysql_jdbc_class}#g" ${hue_scripts_home}/init-hue.sh && \

## hue start and stop script
    chmod +x /usr/local/bin/huerestart && chmod +x /usr/local/bin/huestart && chmod +x /usr/local/bin/huestop && \
    sed -i "s#{hue_install_path}#${hue_install_path}#g" /usr/local/bin/huestart && \
    sed -i "s#{hue_install_path}#${hue_install_path}#g" /usr/local/bin/huestop && \
    chmod +x /usr/local/bin/huelog && \

## cp hue sync db and restart script, need user execute manaully
    sed -i "s#{hue_install_path}#${hue_install_path}#g" /usr/local/bin/huesyncdb && \
    chmod +x /usr/local/bin/huesyncdb && \

## create hue user
    useradd hue || true && \

## mysql8 jdbc connector jar
    mkdir -p ${hue_install_path}/jars && \
    cd $hue_install_path/jars && curl -LO $mysql_jdbc_url && \
    echo "export CLASSPATH=\$CLASSPATH:${hue_install_path}/jars/${mysql_jdbc_file_name}" >> /etc/profile && \

## init service
    echo "sh ${hue_scripts_home}/init-hue.sh && huestart" >> /init_service
