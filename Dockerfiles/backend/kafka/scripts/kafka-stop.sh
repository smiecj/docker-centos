#!/bin/bash

jps -ml | grep "kafka.Kafka" | awk '{print $1}' | xargs --no-run-if-empty kill -9

sleep 3
