#!/bin/bash

jps -ml | grep "org.apache.hadoop.hdfs" | awk '{print $1}' | xargs --no-run-if-empty kill -9
jps -ml | grep "org.apache.hadoop.yarn" | awk '{print $1}' | xargs --no-run-if-empty kill -9
sleep 3
