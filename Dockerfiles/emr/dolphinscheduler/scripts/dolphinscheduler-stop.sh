#!/bin/bash

ps -ef | grep "org.apache.dolphinscheduler.StandaloneServer" | grep -v grep | awk '{print $2}' | xargs --no-run-if-empty kill -9