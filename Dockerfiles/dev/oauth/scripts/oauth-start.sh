#!/bin/bash

pushd {oauth_module_home}
make server_host=${HOST} server_port=${HOST_SERVER_PORT} client_host=${HOST} client_port=${HOST_CLIENT_PORT} run_docker
popd