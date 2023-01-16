#!/bin/bash

nohup superset run -h 0.0.0.0 -p ${PORT} --with-threads --reload --debugger >> {superset_log} 2>&1 &
