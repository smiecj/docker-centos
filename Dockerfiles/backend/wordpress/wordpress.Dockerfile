ARG MINIMAL_IMAGE
FROM ${MINIMAL_IMAGE}

# install wordpress
ENV MYSQL_ADDR=localhost:3306
ENV MYSQL_USER=root
ENV MYSQL_PASSWORD=root
ENV MYSQL_DB=wordpress
ENV HTTPD_PORT=80

### all versions: https://cn.wordpress.org/download/releases/
ARG wordpress_version=5.0.4
ARG wordpress_pkg=wordpress-${wordpress_version}-zh_CN.tar.gz
ARG wordpress_pkg_url=https://cn.wordpress.org/${wordpress_pkg}

ARG wordpress_module_home=/home/modules/wordpress
ARG wordpress_scripts_home=${wordpress_module_home}/scripts

## httpd
RUN yum -y install httpd
COPY s6/ /etc

## php
RUN yum -y install epel-release
RUN yum -y install php php-fpm php-mysqlnd

## rsync
RUN yum -y install rsync

### fpm basic config
RUN sed -i 's/listen.acl_users/;listen.acl_users/g' /etc/php-fpm.d/www.conf && \
    sed -i 's/;listen.mode/listen.mode/g' /etc/php-fpm.d/www.conf && \
    sed -i 's/listen.mode.*/listen.mode = 0777/g' /etc/php-fpm.d/www.conf

## download
RUN cd /tmp && curl -LO $wordpress_pkg_url && tar -xzvf $wordpress_pkg && \
    rsync -avP ./wordpress/ /var/www/html/ && \
    mkdir -p /var/www/html/wp-content/uploads && \
    chown -R apache:apache /var/www/html/* && \
    rm -rf /tmp/wordpress*

## init script
RUN mkdir -p ${wordpress_module_home} && mkdir -p ${wordpress_scripts_home}
COPY ./scripts/init-wordpress.sh ${wordpress_scripts_home}/
RUN echo "sh ${wordpress_scripts_home}/init-wordpress.sh" >> /init_service
