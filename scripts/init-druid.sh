#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

## env init
. ./env_druid.sh

### python3
source /etc/profile
pip3 install pyyaml

set -euxo pipefail

## druid
### download source code
rm -rf $druid_folder_path
curl -LO $druid_pkg_download_url
tar -xzvf $druid_pkg_name
rm -f $druid_pkg_name
pushd $druid_folder_path

### compile
#### bug fix: https://github.com/apache/druid/issues/12274
sed -i 's/yaml.load_all(registry_file)/yaml.load_all(registry_file, Loader=yaml.FullLoader)/g' distribution/bin/generate-binary-license.py
sed -i 's/yaml.load_all(registry_file)/yaml.load_all(registry_file, Loader=yaml.FullLoader)/g' distribution/bin/generate-binary-notice.py

mvn clean install -Pdist,rat -DskipTests

rm -rf $druid_module_home
mkdir -p $druid_module_home
mv ./distribution/target/$druid_bin_pkg_name $druid_module_home
popd

rm -rf $druid_folder_path

pushd $druid_module_home
tar -xzvf $druid_bin_pkg_name
rm -f $druid_bin_pkg_name
popd

### start and stop script
cp -f ./env_druid.sh /usr/local/bin
cp -f $home_path/../components/druid/druid-restart.sh /usr/local/bin/druidrestart
chmod +x /usr/local/bin/druidrestart
cp -f $home_path/../components/druid/druid-stop.sh /usr/local/bin/druidstop
chmod +x /usr/local/bin/druidstop

popd