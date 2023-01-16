#!/bin/bash

cd {ant_design_home} && port=${PORT} nohup npm start > {ant_design_log} 2>&1 &
