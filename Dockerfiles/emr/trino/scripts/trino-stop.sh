#!/bin/bash

export JAVA_HOME=`cat /etc/profile | grep JDK_HOME | sed 's#.* ##g'`
export PATH=${JAVA_HOME}/bin:$PATH

{trino_module_home}/bin/launcher stop

sleep 3