ARG HUE_BASE_IMAGE
FROM ${HUE_BASE_IMAGE}

# install hue

ENV mysql_host=localhost
ENV mysql_port=3306
ENV mysql_db=hive
ENV mysql_user=hive
ENV mysql_pwd=hive

ENV PORT=8281

ARG hue_install_prefix=/usr/local
ARG hue_install_path=${hue_install_prefix}/hue
ARG hue_code_url=https://github.com/smiecj/hue/archive/refs/heads/dev_bugfix.zip
ARG hue_code_pkg=dev_bugfix.zip
ARG hue_code_folder=hue-dev_bugfix
ARG code_home=/tmp
ARG hue_code_home=${code_home}/${hue_code_folder}
ARG hue_scripts_home=${hue_install_path}${hue_scripts_home}/

ARG mysql_version=8.0.26
ARG mysql_jdbc_url=https://repo1.maven.org/maven2/mysql/mysql-connector-java/${mysql_version}/mysql-connector-java-${mysql_version}.jar
ARG mysql_jdbc_file_name=mysql-connector-java-${mysql_version}.jar
ARG mysql_jdbc_class=com.mysql.cj.jdbc.Driver

## basic env
RUN yum -y install make gcc gcc-c++ cmake cyrus-sasl-devel cyrus-sasl-gssapi cyrus-sasl-plain libffi-devel libxml2 libxml2-devel libxslt libxslt-devel mysql mysql-devel openldap-devel sqlite-devel gmp-devel python2-devel

## compile hue source code

RUN cd ${code_home} && curl -LO ${hue_code_url} && unzip ${hue_code_pkg} && cd ${hue_code_folder}
COPY ./cdh-root-6.3.3.pom ${hue_code_home}/maven
RUN sed -i 's/<version>6.3.3<\/version>/<version>6.3.3<\/version>\n<relativePath>.\/cdh-root-6.3.3.pom<\/relativePath>/g' ${hue_code_home}/maven/pom.xml

RUN cd ${hue_code_home} && source /etc/profile && PREFIX=${hue_install_prefix} make install
RUN rm -rf ${hue_code_home}

## hue config
RUN mkdir -p ${hue_install_path}/build/static/desktop
RUN yes | cp -r ${hue_install_path}/desktop/core/src/desktop/static/desktop/js ${hue_install_path}/build/static/desktop

RUN cd ${hue_install_path}/desktop/conf && mv pseudo-distributed.ini.tmpl hue.ini && cp hue.ini hue.ini_example

RUN mkdir -p ${hue_scripts_home}
COPY ./scripts/init-hue.sh ${hue_scripts_home}/
RUN sed -i "s#{hue_install_path}#${hue_install_path}#g" ${hue_scripts_home}/init-hue.sh && \
    sed -i "s#{mysql_jdbc_class}#${mysql_jdbc_class}#g" ${hue_scripts_home}/init-hue.sh

## hue start and stop script
COPY ./scripts/hue-restart.sh /usr/local/bin/huerestart
COPY ./scripts/hue-start.sh /usr/local/bin/huestart
COPY ./scripts/hue-stop.sh /usr/local/bin/huestop
RUN chmod +x /usr/local/bin/huerestart && chmod +x /usr/local/bin/huestart && chmod +x /usr/local/bin/huestop
RUN sed -i "s#{hue_install_path}#${hue_install_path}#g" /usr/local/bin/huestart && \
    sed -i "s#{hue_install_path}#${hue_install_path}#g" /usr/local/bin/huestop

## cp hue sync db and restart script, need user execute manaully
COPY ./scripts/hue-syncdb.sh /usr/local/bin/huesyncdb
RUN sed -i "s#{hue_install_path}#${hue_install_path}#g" /usr/local/bin/huesyncdb && \
    chmod +x /usr/local/bin/huesyncdb

## create hue user
RUN useradd hue || true

## mysql8 jdbc connector jar
RUN mkdir -p ${hue_install_path}/jars
RUN cd $hue_install_path/jars curl -LO $mysql_jdbc_url && \
    echo "export CLASSPATH=\$CLASSPATH:${hue_install_path}/jars/${mysql_jdbc_file_name}" >> /etc/profile

## init service
RUN echo "sh ${hue_scripts_home}/init-hue.sh && huestart" >> /init_service
