#!/bin/bash
cd {grafana_module_home}/conf
cp sample.ini custom.ini
sed -i "s/http_port =.*/http_port = ${PORT}/g" custom.ini
