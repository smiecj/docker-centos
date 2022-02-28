system_arch=`uname -p`
prometheus_version=2.33.4
alertmanager_version=0.23.0
prometheus_download_url=https://github.com/prometheus/prometheus/releases/download/v$prometheus_version/prometheus-$prometheus_version.linux-armv7.tar.gz
alertmanager_download_url=https://github.com/prometheus/alertmanager/releases/download/v$alertmanager_version/alertmanager-$alertmanager_version.linux-armv7.tar.gz

if [ "$system_arch" == "x86_64" ]; then
    prometheus_download_url=https://github.com/prometheus/prometheus/releases/download/v$prometheus_version/prometheus-$prometheus_version.linux-amd64.tar.gz
    alertmanager_download_url=https://github.com/prometheus/alertmanager/releases/download/v$alertmanager_version/alertmanager-$alertmanager_version.linux-amd64.tar.gz
fi

prometheus_pkg=`echo $prometheus_download_url | sed 's/.*\///g'`
alertmanager_pkg=`echo $alertmanager_download_url | sed 's/.*\///g'`

prometheus_folder=`echo $prometheus_pkg | sed 's/.tar.*//g'`
alertmanager_folder=`echo $alertmanager_pkg | sed 's/.tar.*//g'`

prometheus_module_home=/home/modules/prometheus
prometheus_full_path=$prometheus_module_home/$prometheus_folder
alertmanager_full_path=$prometheus_module_home/$alertmanager_folder

prometheus_port=3001
alertmanager_port=2113