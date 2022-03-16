#!/bin/bash
#set -euxo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

sh ./init-system-python.sh

curl -LO https://github.com/smiecj/python-tools/archive/refs/heads/main.zip
unzip main.zip
pushd python-tools-main
make install_pip2pi
popd

rm -f main.zip
rm -rf python-tools-main

popd