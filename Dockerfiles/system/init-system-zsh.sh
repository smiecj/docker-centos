#!/bin/bash

pushd /tmp

shell_tools_version=`echo ${shell_tools_tag} | sed 's#v##g'`

curl -LO ${github_url}/smiecj/shell-tools/archive/refs/tags/${shell_tools_tag}.tar.gz
tar -xzvf ${shell_tools_tag}.tar.gz
rm ${shell_tools_tag}.tar.gz
cd shell-tools-${shell_tools_version}
NET=${NET} make zsh
cd /tmp
rm -r shell-tools-${shell_tools_version}

popd