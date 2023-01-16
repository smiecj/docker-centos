#!/bin/bash

pushd {kafka_eagle_module_home}
./bin/ke.sh cluster restart
popd