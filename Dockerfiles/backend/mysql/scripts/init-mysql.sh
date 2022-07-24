#!/bin/bash

# init mysql (only for first time)
## refer: mysql official entrypoint.sh: https://github.com/docker-library/mysql/blob/master/5.7/docker-entrypoint.sh

## get default password
origin_mysql_password=`cat ${mysql_log_file} | grep 'temporary password' | sed 's/.*temporary password.* //g'`
if [ -z "$origin_mysql_password" ]; then
    echo "origin mysql password not exist, will exit init"
    exit
fi

## temporaily start mysql
nohup /usr/sbin/mysqld --user=root > /dev/null 2>&1 &
sleep 2

mysql_version=`mysql -V`

if [[ "$mysql_version" =~ .*8.[0-9]+.[0-9]+ ]]; then
    ## set root password
    mysql -uroot -p"$origin_mysql_password" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASSWORD}';" --connect-expired-password
    mysql -uroot -p"${ROOT_PASSWORD}" -e "UPDATE mysql.user SET host = '%' WHERE user = 'root'"

    ## set user db
    if [ -n "${USER_DB}" ]; then
        mysql -uroot -p"${ROOT_PASSWORD}" -e "CREATE DATABASE ${USER_DB}"
    fi

    ## execute init sql
    sql_files=`ls -l {mysql_init_sql_home} | grep -E "\.sql$" | sed "s/.* //g" | tr '\n' ' '`
    for current_sql_file in ${sql_files[@]}
    do
        mysql -uroot -p"${ROOT_PASSWORD}" -f -D${USER_DB} < {mysql_init_sql_home}/${current_sql_file}
    done

    ### todo: add user account with permission
fi

## close mysql
/usr/bin/mysqladmin -uroot -p${ROOT_PASSWORD} shutdown

## remove origin mysql log
echo "" > ${mysql_log_file}

## todo: rotate mysql log
### https://knowledge.broadcom.com/external/article/106971/varlog-full-because-of-very-large-mysqld.html