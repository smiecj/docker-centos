#!/bin/bash

su ${pgsql_user} -c "postmaster -D ${DATA_DIR} > /dev/null 2>&1 &"