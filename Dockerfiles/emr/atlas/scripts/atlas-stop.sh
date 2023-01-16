#!/bin/bash

jps -ml | grep "org.apache.atlas.Atlas" | awk '{print $1}' | xargs --no-run-if-empty kill -9
jps -ml | grep "org.apache.hadoop.hbase.master.HMaster" | awk '{print $1}' | xargs --no-run-if-empty kill -9