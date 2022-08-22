#!/bin/bash

## for docker in docker, must set 777 to sock
sock_permission=`stat -c %a /var/run/docker.sock || true`
if [ "777" != "$sock_permission" ]; then
    chmod 777 /var/run/docker.sock || true
fi

nohup su - jenkins -s /bin/bash -c "JENKINS_PORT=${PORT} JAVA_OPTS='-Djava.awt.headless=true' /usr/bin/jenkins" > {jenkins_log} 2>&1 &
