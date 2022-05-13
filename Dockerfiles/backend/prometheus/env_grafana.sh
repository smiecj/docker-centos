system_arch=`uname -p`

grafana_download_url=https://mirrors.huaweicloud.com/grafana/${grafana_version}/grafana-enterprise-${grafana_version}.linux-arm64.tar.gz

if [ "$system_arch" == "x86_64" ]; then
    grafana_download_url=https://mirrors.huaweicloud.com/grafana/${grafana_version}/grafana-enterprise-${grafana_version}.linux-amd64.tar.gz
fi

grafana_pkg=`echo $grafana_download_url | sed 's/.*\///g'`
grafana_folder="grafana-$grafana_version"
