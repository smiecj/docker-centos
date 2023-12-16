#!/bin/bash

# install s6

arch=`uname -p`

s6_noarch_tar_download_url="${github_url}/just-containers/s6-overlay/releases/download/${s6_version}/s6-overlay-noarch.tar.xz"
s6_arch_tar_download_url="${github_url}/just-containers/s6-overlay/releases/download/${s6_version}/s6-overlay-${arch}.tar.xz"

s6_noarch_tar=`echo ${s6_noarch_tar_download_url} | sed 's/.*\///g'`
s6_arch_tar=`echo ${s6_arch_tar_download_url} | sed 's/.*\///g'`

pushd /tmp

curl -LO $s6_noarch_tar_download_url
curl -LO $s6_arch_tar_download_url
tar -xvf $s6_noarch_tar -C /
tar -xvf $s6_arch_tar -C /
rm $s6_noarch_tar
rm $s6_arch_tar

popd
