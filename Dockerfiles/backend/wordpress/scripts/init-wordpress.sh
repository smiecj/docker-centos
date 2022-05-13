#!/bin/bash
pushd /var/www/html/

cp wp-config-sample.php wp-config.php
sed -i "s/'localhost'/'$MYSQL_ADDR'/g" wp-config.php
sed -i "s/username_here/$MYSQL_USER/g" wp-config.php
sed -i "s/password_here/$MYSQL_PASSWORD/g" wp-config.php
sed -i "s/database_name_here/$MYSQL_DB/g" wp-config.php

sed -i "s/^Listen .*/Listen $HTTPD_PORT/g" /etc/httpd/conf/httpd.conf

popd