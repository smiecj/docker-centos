#!/bin/bash

pushd {navidrome_module_home}

cp navidrome.toml.template navidrome.toml

env_keys=`printenv | sed "s#=.*##g"`

for current_env_key in ${env_keys[@]}
do
    sed -i "s#{${current_env_key}}#${!current_env_key}#g" navidrome.toml
done

mkdir -p ${MUSIC_FOLDER}
mkdir -p ${DATA_FOLDER}

popd