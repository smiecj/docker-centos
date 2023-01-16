#!/bin/bash

source /etc/profile

hue_start_log=/tmp/hue_start.log

## init db
huesyncdb > ${hue_start_log} 2>&1

## create admin user
{hue_install_path}/build/env/bin/hue createsuperuser --username ${ADMIN_USER} --email ${ADMIN_MAIL} --noinput > ${hue_start_log} 2>&1 || true
### support --password arg: https://github.com/smiecj/hue/commit/337a69b316adc7d6dda507b931c394ab6965e1e8
{hue_install_path}/build/env/bin/hue changepassword ${ADMIN_USER} --password ${ADMIN_PASSWORD} >> ${hue_start_log} 2>&1 || true

## start
mkdir -p /var/run/hue && chmod -R 777 /var/run/hue
{hue_install_path}/build/env/bin/supervisor -p /var/run/hue/supervisor.pid -l /var/log/hue -d
