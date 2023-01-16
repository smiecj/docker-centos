ARG IMAGE_MINIMAL
FROM ${IMAGE_MINIMAL}

# install wordpress
ENV MYSQL_ADDR=localhost:3306
ENV MYSQL_USER=root
ENV MYSQL_PASSWORD=root
ENV MYSQL_DB=wordpress
ENV HTTPD_PORT=80

### all versions: https://cn.wordpress.org/download/releases/
ARG module_home
ARG wordpress_version

## httpd
COPY s6/ /etc
COPY ./scripts/init-wordpress.sh /tmp

RUN wordpress_module_home=${module_home}/wordpress && \
    wordpress_scripts_home=${wordpress_module_home}/scripts && \
    wordpress_pkg=wordpress-${wordpress_version}-zh_CN.tar.gz && \
    wordpress_pkg_url=https://cn.wordpress.org/${wordpress_pkg} && \

    yum -y install httpd && \
## php
    yum -y install epel-release \
    php php-fpm php-mysqlnd \
## rsync
    rsync && \

### fpm basic config
    sed -i 's/listen.acl_users/;listen.acl_users/g' /etc/php-fpm.d/www.conf && \
    sed -i 's/;listen.mode/listen.mode/g' /etc/php-fpm.d/www.conf && \
    sed -i 's/listen.mode.*/listen.mode = 0777/g' /etc/php-fpm.d/www.conf && \

## download
    cd /tmp && curl -LO $wordpress_pkg_url && tar -xzvf $wordpress_pkg && \
    rsync -avP ./wordpress/ /var/www/html/ && \
    mkdir -p /var/www/html/wp-content/uploads && \
    chown -R apache:apache /var/www/html/* && \
    rm -rf /tmp/wordpress* && \

## init script
    mkdir -p ${wordpress_module_home} && mkdir -p ${wordpress_scripts_home} && \
    mv /tmp/init-wordpress.sh ${wordpress_scripts_home}/ && \
    echo "sh ${wordpress_scripts_home}/init-wordpress.sh" >> /init_service
