#!/bin/bash
set -euxo pipefail

jupyter_home=/home/modules/jupyter
rm -rf $jupyter_home
mkdir -p $jupyter_home
pushd $jupyter_home

curl -LO https://github.com/smiecj/python-tools/archive/refs/heads/main.zip
unzip main.zip
pushd python-tools-main

make install_conda
source /etc/profile
make install_jupyter

popd

popd