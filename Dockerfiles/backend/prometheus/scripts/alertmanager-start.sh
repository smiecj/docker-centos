#!/bin/bash

nohup {alertmanager_module_home}/alertmanager --config.file={alertmanager_module_home}/alertmanager.yml --web.listen-address=:$ALERTMANAGER_PORT > {alertmanager_log} 2>&1 &
