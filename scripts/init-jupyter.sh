#!/bin/bash
set -euxo pipefail

jupyter_home=/home/modules/jupyter
rm -rf $jupyter_home
mkdir -p $jupyter_home
cd $jupyter_home

wget https://github.com/smiecj/python-tools/archive/refs/heads/main.zip
unzip main.zip
cd python-tools-main

make install_conda
source /etc/profile
make install_jupyter
