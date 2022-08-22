#!/bin/bash

# gateway-site.xml
pushd {knox_module_home}/conf
cp gateway-site_template.xml gateway-site.xml

## port
sed -i "s/{PORT}/${KNOX_PORT}/g" gateway-site.xml

popd

# sandbox
pushd {knox_module_home}/conf/topologies/

cp sandbox_template.xml sandbox.xml

## env
sed -i "s/{WEBHDFS_ADDRESS}/${WEBHDFS_ADDRESS}/g" sandbox.xml
sed -i "s/{YARN_ADDRESS}/${YARN_ADDRESS}/g" sandbox.xml

popd

# create master
if [ ! -f {knox_module_home}/data/security/master ]; then
    {knox_module_home}/bin/knoxcli.sh create-master --master knox123 --generate
fi
