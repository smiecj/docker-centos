#!/bin/bash

source /etc/profile

mongod --dbpath ${mongo_data_home} --logpath ${mongo_log_home}/${mongo_log} --bind_ip 0.0.0.0 --port ${PORT} --fork
