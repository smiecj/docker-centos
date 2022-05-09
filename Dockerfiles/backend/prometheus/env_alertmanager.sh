system_arch=`uname -p`
alertmanager_download_url=https://github.com/prometheus/alertmanager/releases/download/v${alertmanager_version}/alertmanager-${alertmanager_version}.linux-armv7.tar.gz

if [ "$system_arch" == "x86_64" ]; then
    alertmanager_download_url=https://github.com/prometheus/alertmanager/releases/download/v${alertmanager_version}/alertmanager-${alertmanager_version}.linux-amd64.tar.gz
fi

alertmanager_pkg=`echo $alertmanager_download_url | sed 's/.*\///g'`
alertmanager_folder=`echo $alertmanager_pkg | sed 's/.tar.*//g'`
