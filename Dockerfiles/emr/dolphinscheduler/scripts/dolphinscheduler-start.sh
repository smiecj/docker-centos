#!/bin/bash

pushd {dolphinscheduler_module_home}
bash ./bin/dolphinscheduler-daemon.sh start standalone-server
popd