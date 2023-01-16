#!/bin/bash

ps -ef | grep "org.elasticsearch.bootstrap.Elasticsearch" | grep -v grep | awk '{print $2}' | xargs --no-run-if-empty kill -9