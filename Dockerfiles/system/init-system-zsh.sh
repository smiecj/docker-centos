#!/bin/bash

pushd /tmp

curl ${github_url}/smiecj/shell-tools/archive/refs/tags/v1.0.tar.gz
tar -xzvf v1.0.tar.gz
rm v1.0.tar.gz
cd shell-tools-1.0
make zsh
cd /tmp
rm -r shell-tools-1.0

popd