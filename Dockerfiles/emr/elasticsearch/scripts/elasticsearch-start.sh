#!/bin/bash

su {ES_USER} -c "nohup {es_module_home}/bin/elasticsearch > /dev/null 2>&1 &"