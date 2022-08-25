#!/bin/bash

source /etc/profile

## init db
huesyncdb

## create admin user
{hue_install_path}/build/env/bin/hue createsuperuser --username ${ADMIN_USER} --email ${ADMIN_MAIL} --noinput || true
expect -c "spawn {hue_install_path}/build/env/bin/hue changepassword ${ADMIN_USER};expect Password:;send \"${ADMIN_PASSWORD}\n\";expect Password;send \"${ADMIN_PASSWORD}\n\";interact"

## start
mkdir -p /var/run/hue && chmod -R 777 /var/run/hue
{hue_install_path}/build/env/bin/supervisor -p /var/run/hue/supervisor.pid -l /var/log/hue -d
