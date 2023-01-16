#!/bin/bash

## trino need jdk11
## https://trino.io/docs/current/release/release-330.html#server
export JAVA_HOME=`cat /etc/profile | grep JDK_HOME | sed 's#.* ##g'`
export PATH=${JAVA_HOME}/bin:$PATH
{trino_module_home}/bin/launcher start