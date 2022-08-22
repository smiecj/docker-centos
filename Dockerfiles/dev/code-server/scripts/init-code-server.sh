#!/bin/bash

source /etc/profile

cp {code_server_config_template_file} {code_server_config_file}

# server config
sed -i "s/{PORT}/${PORT}/g" {code_server_config_file}
sed -i "s/{PASSWORD}/${PASSWORD}/g" {code_server_config_file}

# user config
user_config_home=$HOME/.local/share/code-server/User
user_config_file=$user_config_home/settings.json
if [ ! -f $user_config_file ]; then
    echo "hahaha" >> /tmp/test.log
    mkdir -p $user_config_home
    cp {code_server_config_home}/settings_template.json $user_config_file
    if [ "dark" == "${theme}" ]; then
        sed -i "s#{theme}#Default Dark+#g" $user_config_file
    else
        sed -i "s#{theme}#Default Light+#g" $user_config_file
    fi
    sed -i "s#{font}#${font}#g" $user_config_file
    sed -i "s#{java_home}#${JDK_HOME}#g" $user_config_file
fi