#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ./env_zookeeper.sh

$zookeeper_pkg_home/bin/zkCli.sh -server 127.0.0.1:{port}