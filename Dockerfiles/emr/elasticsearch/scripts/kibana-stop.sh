#!/bin/bash

ps -ef | grep "{kibana_module_home}" | grep -v grep | awk '{print $2}' | xargs --no-run-if-empty kill -9