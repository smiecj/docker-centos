system_arch=`uname -p`
prometheus_version=2.33.4
prometheus_download_url=https://github.com/prometheus/prometheus/releases/download/v${prometheus_version}/prometheus-${prometheus_version}.linux-armv7.tar.gz

if [ "$system_arch" == "x86_64" ]; then
    prometheus_download_url=https://github.com/prometheus/prometheus/releases/download/v${prometheus_version}/prometheus-${prometheus_version}.linux-amd64.tar.gz
fi

prometheus_pkg=`echo $prometheus_download_url | sed 's/.*\///g'`
prometheus_folder=`echo $prometheus_pkg | sed 's/.tar.*//g'`
