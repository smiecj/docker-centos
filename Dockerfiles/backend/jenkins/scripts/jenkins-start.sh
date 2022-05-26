#!/bin/bash

nohup su - jenkins -s /bin/bash -c "JENKINS_PORT=${PORT} JAVA_OPTS='-Djava.awt.headless=true' /usr/bin/jenkins" > {jenkins_log} 2>&1 &

