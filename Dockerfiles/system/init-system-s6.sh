#!/bin/bash

# install s6

arch="amd64"

system_arch=`uname -p`
if [[ "aarch64" == "$system_arch" ]]; then
    arch="arm"
fi

s6_installer_download_url="https://github.com/just-containers/s6-overlay/releases/download/${s6_version}/s6-overlay-${arch}-installer"
s6_installer=`echo $s6_installer_download_url | sed 's/.*\///g'`

pushd /tmp

curl -LO $s6_installer_download_url
chmod +x $s6_installer
./$s6_installer
rm -f $s6_installer

popd