#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ./env_system.sh

## judge system architecture and decide some variable value
system_arch=`uname -p`

go_version=1.17.5
go_download_url=https://go.dev/dl/go$go_version.linux-amd64.tar.gz
go_pkg=`echo $go_download_url | sed 's/.*\///g'`

if [ "x86_64" == "$system_arch" ]; then
    echo "The system arch is x86_64"
else
    go_download_url=https://go.dev/dl/go$go_version.linux-arm64.tar.gz
    go_pkg=`echo $go_download_url | sed 's/.*\///g'`
fi

## golang install
go_home=/usr/golang
go_repo_home=$repo_home/go
rm -rf $go_home
rm -rf $go_repo_home
mkdir -p $go_home
mkdir -p $go_repo_home
pushd $go_home
rm -rf *
curl -LO $go_download_url
tar -xzvf $go_pkg
rm -f $go_pkg
popd

### golang environment
echo -e '\n# go' >> /etc/profile
echo "export GOROOT=$go_home/go" >> /etc/profile
echo "export GOPATH=$go_repo_home" >> /etc/profile
echo 'export PATH=$PATH:$GOROOT/bin:$GOPATH/bin' >> /etc/profile

popd