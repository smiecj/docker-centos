## judge system architecture and decide some variable value
system_arch=`uname -p`

go_download_url=https://go.dev/dl/go$go_version.linux-amd64.tar.gz
go_pkg=`echo $go_download_url | sed 's/.*\///g'`

if [ "x86_64" == "$system_arch" ]; then
    echo "The system arch is x86_64"
else
    go_download_url=https://go.dev/dl/go$go_version.linux-arm64.tar.gz
    go_pkg=`echo $go_download_url | sed 's/.*\///g'`
fi