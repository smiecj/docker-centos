system_arch=`uname -p`
grafana_version=8.4.2

grafana_download_url=https://mirrors.huaweicloud.com/grafana/$grafana_version/grafana-enterprise-$grafana_version.linux-arm64.tar.gz

if [ "$system_arch" == "x86_64" ]; then
    grafana_download_url=https://mirrors.huaweicloud.com/grafana/$grafana_version/grafana-enterprise-$grafana_version.linux-amd64.tar.gz
fi

grafana_pkg=`echo $grafana_download_url | sed 's/.*\///g'`

grafana_folder="grafana-$grafana_version"

grafana_module_home=/home/modules/grafana
grafana_full_path=$grafana_module_home/$grafana_folder

grafana_config_file=grafana.ini

grafana_port=3000