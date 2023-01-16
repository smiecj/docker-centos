#!/bin/bash

ps -ef | grep "nginx: master process" | grep -v grep | awk '{print $2}' | xargs --no-run-if-empty kill -9

ps -ef | grep "nginx: worker process" | grep -v grep | awk '{print $2}' | xargs --no-run-if-empty kill -9