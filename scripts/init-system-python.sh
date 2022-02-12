#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

pushd /tmp
rm -f main.zip
rm -rf python-tools-main
curl -LO https://github.com/smiecj/python-tools/archive/refs/heads/main.zip
unzip main.zip
pushd python-tools-main
make install_conda
popd
rm -rf python-tools-main
rm -f main.zip
popd

### python environment
echo 'export PYTHON3_HOME=/usr/local/miniconda/envs/py3' >> /etc/profile
echo 'export PATH=$PATH:$PYTHON3_HOME/bin' >> /etc/profile

popd