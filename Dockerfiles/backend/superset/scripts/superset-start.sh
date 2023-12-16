#!/bin/bash

export SUPERSET_SECRET_KEY=`echo "{superset_secret_key}" | base64`
nohup superset run -h 0.0.0.0 -p ${PORT} --with-threads --reload --debugger >> {superset_log} 2>&1 &
