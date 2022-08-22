#!/bin/bash

source /etc/profile

nohup {code_server_module_home}/code-server --config {code_server_config_file} >> {code_server_log} 2>&1 &