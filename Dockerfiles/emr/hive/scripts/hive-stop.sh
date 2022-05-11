#!/bin/bash

jps -ml | grep "{hive_module_home}" | awk '{print $1}' | xargs --no-run-if-empty kill -9
sleep 3