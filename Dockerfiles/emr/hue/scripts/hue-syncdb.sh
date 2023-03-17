#!/bin/bash

# wait mysql start finish
while :
do
    mysql_connect_ret_exec=`mysql -u${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USER} -p${MYSQL_PASSWORD} -e "select version()"`
    mysql_connect_ret=$?
    if [[ 0 == ${mysql_connect_ret} ]]; then
        echo "mysql has start"
        break
    else
        echo "mysql has not start, will wait for it"
        sleep 3
    fi
done

# check whether table has created
table_check=`mysql -u${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USER} -p${MYSQL_PASSWORD} -D${MYSQL_DB} -e "show create table desktop_document2"`
table_check_ret=$?
if [[ 0 != $table_check_ret ]]; then
    {hue_install_path}/build/env/bin/hue syncdb --noinput
    {hue_install_path}/build/env/bin/hue migrate
    mysql -u${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USER} -p${MYSQL_PASSWORD} -e "alter database ${MYSQL_DB} character set utf8"
    mysql -u${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USER} -p${MYSQL_PASSWORD} -D${MYSQL_DB} -e "ALTER TABLE desktop_document2 CHARACTER SET utf8, COLLATE utf8_general_ci"
    mysql -u${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USER} -p${MYSQL_PASSWORD} -D${MYSQL_DB} -e "alter table beeswax_queryhistory modify `query` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL"
    mysql -u${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USER} -p${MYSQL_PASSWORD} -D${MYSQL_DB} -e "ALTER TABLE desktop_document2 modify column name varchar(255) CHARACTER SET utf8"
    mysql -u${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USER} -p${MYSQL_PASSWORD} -D${MYSQL_DB} -e "ALTER TABLE desktop_document2 modify column description longtext CHARACTER SET utf8"
    mysql -u${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USER} -p${MYSQL_PASSWORD} -D${MYSQL_DB} -e "ALTER TABLE desktop_document2 modify column search longtext CHARACTER SET utf8"
fi