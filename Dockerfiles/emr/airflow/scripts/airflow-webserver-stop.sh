#!/bin/bash

ps -ef | grep 'airflow webserver' | grep -v grep | awk '{print $2}' | xargs --no-run-if-empty kill -9

ps -ef | grep 'airflow-webserver' | grep -v grep | awk '{print $2}' | xargs --no-run-if-empty kill -9

sleep 3