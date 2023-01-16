#!/bin/bash

su ${pgsql_user} -c "pg_ctl stop -D ${DATA_DIR} -m smart"
