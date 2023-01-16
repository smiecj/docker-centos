#!/bin/bash

pushd {nginx_module_home}
cp nginx.conf_template nginx.conf

sed -i "s#{PORT}#${PORT}#g" nginx.conf

popd
