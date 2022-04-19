# node install envs

npm_download_url=https://mirrors.tuna.tsinghua.edu.cn/nodejs-release/$node_version/node-$node_version-linux-x64.tar.gz
npm_pkg=`echo $npm_download_url | sed 's/.*\///g'`
npm_folder=node-$node_version-linux-x64

system_arch=`uname -p`
if [ "x86_64" == "$system_arch" ]; then
    echo "The system arch is x86_64"
else
    npm_download_url=https://mirrors.tuna.tsinghua.edu.cn/nodejs-release/$node_version/node-$node_version-linux-arm64.tar.gz
    npm_pkg=`echo $npm_download_url | sed 's/.*\///g'`
    npm_folder=node-$node_version-linux-arm64
fi
