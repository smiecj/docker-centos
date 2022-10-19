#!/bin/bash

pushd {zeppelin_module_home}/conf

cp zeppelin-site.xml.template zeppelin-site.xml

sed -i "s/{PORT}/${PORT}/g" zeppelin-site.xml

popd
