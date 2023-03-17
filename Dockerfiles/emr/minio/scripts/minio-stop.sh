#!/bin/bash

ps -ef | grep "minio server" | grep -v grep | awk '{print $2}' | xargs -I {} bash -c "kill -9 {}"
