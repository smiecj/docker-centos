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
make install_jupyter

# 当前: 直接在空容器上自行测试