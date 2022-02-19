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
## centos8 通过conda安装 python3.7 以上版本目前有问题: conda lib 缺少 libtirpc 导致 pamela 会执行失败，影响 jupyter 安装
## 因此暂时使用 yum 方法安装 python, 详细代码参考 python-tools install_python3.sh
centos_version=`cat /etc/redhat-release | sed 's/.*release //g' | sed 's/ .*//g'`
system_arch=`uname -p`
if [[ $centos_version =~ 8.* ]]; then
    make install_python3
else
    make install_conda
fi

popd
rm -rf python-tools-main
rm -f main.zip
popd

popd