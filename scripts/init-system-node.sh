#!/bin/bash

. ./env_system.sh

npm_download_url=https://nodejs.org/dist/v14.17.0/node-v14.17.0-linux-x64.tar.gz
npm_pkg=`echo $npm_download_url | sed 's/.*\///g'`
npm_folder=`echo $npm_pkg | sed 's/\.tar.gz.*//g'`

system_arch=`uname -p`
if [ "x86_64" == "$system_arch" ]; then
    echo "The system arch is x86_64"
else
    npm_download_url=https://nodejs.org/dist/v14.17.0/node-v14.17.0-linux-arm64.tar.gz
    npm_pkg=`echo $npm_download_url | sed 's/.*\///g'`
    npm_folder=`echo $npm_pkg | sed 's/\.tar.gz.*//g'`
fi

mkdir -p $npm_home
mkdir -p $npm_repo_home
cd $npm_home
rm -rf *
npm_home="$npm_home/$npm_folder"
curl -LO $npm_download_url
tar -xzvf $npm_pkg
rm -f $npm_pkg

### npm environment
echo -e '\n# nodejs' >> /etc/profile
#echo 'export NODE_HOME=/usr/nodejs/node-v14.17.0-linux-arm64' >> /etc/profile
echo "export NODE_HOME=$npm_home" >> /etc/profile
echo "export NODE_REPO=$npm_repo_home/global_modules" >> /etc/profile
echo 'export PATH=$PATH:$NODE_HOME/bin' >> /etc/profile

echo "prefix = $npm_repo_home/global_modules" >> $npm_home/lib/node_modules/npm/.npmrc
echo "cache = $npm_repo_home/cache" >> $npm_home/lib/node_modules/npm/.npmrc