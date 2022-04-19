#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ./env_system.sh


mkdir -p $npm_home
mkdir -p $npm_repo_home
pushd $npm_home
rm -rf *
npm_home="$npm_home/$npm_folder"
curl -LO $npm_download_url
tar -xzvf $npm_pkg
rm -f $npm_pkg

### npm environment
echo -e '\n# nodejs' >> /etc/profile
echo "export NODE_HOME=$npm_home" >> /etc/profile
echo "export NODE_REPO=$npm_repo_home/global_modules" >> /etc/profile
echo 'export PATH=$PATH:$NODE_HOME/bin:$NODE_REPO/bin' >> /etc/profile

echo "prefix = $npm_repo_home/global_modules" >> $npm_home/lib/node_modules/npm/.npmrc
echo "cache = $npm_repo_home/cache" >> $npm_home/lib/node_modules/npm/.npmrc

popd