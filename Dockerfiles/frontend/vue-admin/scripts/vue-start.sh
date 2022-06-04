#!/bin/bash

cd {vue_admin_home} && port=${PORT} nohup npm run dev > {vue_admin_log} 2>&1 &
