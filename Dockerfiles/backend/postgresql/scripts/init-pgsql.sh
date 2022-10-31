#!/bin/bash

# init pgsql
source /etc/profile

## init pgsql data directory
if [ ! -d ${DATA_DIR} ]; then
    mkdir -p /opt/data/pgsql
    chown -R ${pgsql_user}:${pgsql_user} ${DATA_DIR}
    chmod -R 750 ${DATA_DIR}
    su ${pgsql_user} -c "initdb -D ${DATA_DIR}"
else
    echo "[init] data dir ${DATA_DIR} has init"
fi

pushd ${DATA_DIR}
pgsql_config=postgresql.conf

## replace template file to config file
ls -l | grep ".template" | sed "s#.* ##g" | xargs -I {} bash -c 'config_file_name=`echo {} | sed "s#.template##g"` && cp {} ${config_file_name}'

## set mysql cnf file
sed -i "s#{PORT}#${PORT}#g" ${pgsql_config}

## init pgsql account
### start pgsql
pgsqlrestart
sleep 2

### updage pgsql(admin) user
su ${pgsql_user} -c "psql -c \"ALTER USER ${pgsql_user} PASSWORD '${POSTGRES_PASSWORD}';\""

### create normal user
if [[ -n "${USER_DB}" && -n "${USER_NAME}" ]]; then
    check_user_exists_ret=`su ${pgsql_user} -c "psql -t -c \"SELECT 1 FROM pg_roles WHERE rolname='${USER_NAME}'\"" | tr -d ' '`
    if [ -z "${check_user_exists_ret}" ]; then
        su ${pgsql_user} -c "psql -c \"CREATE DATABASE ${USER_DB}\""
        su ${pgsql_user} -c "psql -c \"CREATE USER ${USER_NAME} with encrypted password '${USER_PASSWORD}'\""
        su ${pgsql_user} -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE ${USER_DB} TO ${USER_NAME}\""
    fi
fi

### close pgsql
pgsqlstop

popd