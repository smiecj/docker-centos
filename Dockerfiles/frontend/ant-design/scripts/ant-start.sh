#!/bin/bash

cd {ant_home} && port=${PORT} nohup npm start > {ant_log} 2>&1 &
