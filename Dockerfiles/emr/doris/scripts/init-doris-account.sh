#!/bin/bash

# follower: no need init account
if [ -n "${FE_MASTER_HOST}" ]; then
    echo "current node is follower, not need init account"
    exit 0
fi

# connect local doris
connect_with_password=0
while :
do
    ## first: use default no pwd to connect
    doris_connect_ret_exec=`mysql -h127.0.0.1 -P${FE_QUERY_PORT} -uroot -e "show backends"`
    doris_connect_ret=$?
    if [[ 0 != ${doris_connect_ret} ]]; then
        echo "doris connect with no password failed"
    else
        echo "doris connect with no password success"
        break
    fi
    doris_connect_ret_exec=`mysql -h127.0.0.1 -P${FE_QUERY_PORT} -uroot -p${ROOT_PASSWORD} -e "show backends"`
    doris_connect_ret=$?
    if [[ 0 != ${doris_connect_ret} ]]; then
        echo "doris connect with password failed"
    else
        echo "doris connect with password success"
        connect_with_password=1
        break
    fi
    
    echo "doris has not start, will wait for it"
    sleep 3
done

## init account
pwd_param="-p${ROOT_PASSWORD}"
if [[ 0 == ${connect_with_password} ]]; then
    ### change root password
    mysql -h127.0.0.1 -P${FE_QUERY_PORT} -uroot -e "SET PASSWORD FOR 'root' = PASSWORD('${ROOT_PASSWORD}')"
fi

### add backend
if [ -n "${BE_HOSTS}" ]; then
    be_hosts=`echo ${BE_HOSTS} | sed "s#,#\n#g"`
    for current_be_host in ${be_hosts[@]}
    do
        mysql -h127.0.0.1 -P${FE_QUERY_PORT} -uroot ${pwd_param} -e "ALTER SYSTEM ADD BACKEND '${current_be_host}:${BE_HEARTBEAT_PORT}'" || true
    done
fi
echo "add backend finish"

### add follower
if [ -n "${FE_FOLLOWER_HOSTS}" ]; then
    follower_hosts=`echo ${BE_HOSTS} | sed "s#,#\n#g"`
    for current_follower_host in ${follower_hosts[@]}
    do
        mysql -h127.0.0.1 -P${FE_QUERY_PORT} -uroot ${pwd_param} -e "ALTER SYSTEM ADD FOLLOWER '${current_follower_host}:${FE_EDIT_PORT}'" || true
    done
fi
echo "add follower finish"

### add normal user & set permission
if [ -n "${USER_NAME}" ]; then
    mysql -h127.0.0.1 -P${FE_QUERY_PORT} -uroot ${pwd_param} -e "CREATE USER '${USER_NAME}' IDENTIFIED by '${USER_PASSWORD}';')" || true
    mysql -h127.0.0.1 -P${FE_QUERY_PORT} -uroot ${pwd_param} -e "GRANT SELECT_PRIV,LOAD_PRIV,ALTER_PRIV,CREATE_PRIV,DROP_PRIV ON ${USER_DB}.* TO '${USER_NAME}'@'%';')"
    mysql -h127.0.0.1 -P${FE_QUERY_PORT} -uroot ${pwd_param} -e "CREATE DATABASE ${USER_DB}" || true
fi
echo "add user finish"

echo "doris account init finish!"