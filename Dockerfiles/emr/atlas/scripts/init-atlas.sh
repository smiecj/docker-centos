#!/bin/bash

pushd {atlas_module_home}/conf

## copy config
cp atlas-application.properties_template atlas-application.properties

## set config
sed -i "s/{PORT}/${PORT}/g" atlas-application.properties

popd