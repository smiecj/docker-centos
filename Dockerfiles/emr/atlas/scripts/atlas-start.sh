#!/bin/bash

pushd {atlas_module_home}
export MANAGE_LOCAL_HBASE=true
export MANAGE_LOCAL_SOLR=true
bin/atlas_start.py

popd