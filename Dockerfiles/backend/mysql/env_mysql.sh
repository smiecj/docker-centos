## env init
system_arch=`uname -p`

mysql_version="8.0"
#mysql_version="5.7"
mysql_sub_version="8.0.27-1"
#mysql_sub_version="5.7.36-1"
system_version="el7"
mysql_home=/home/modules/mysql
mysql_repo_home=/home/modules/mysql/repo

#mysql_repo_url="https://cdn.mysql.com/Downloads"
mysql_repo_url="https://mirrors.tuna.tsinghua.edu.cn/mysql/downloads"

mysql_server_rpm_name="mysql-server.rpm"
mysql_common_rpm_name="mysql-common.rpm"
mysql_client_rpm_name="mysql-client.rpm"
mysql_client_plugins_rpm_name="mysql-client-plugins.rpm"
mysql_libs_rpm_name="mysql-libs.rpm"

mysql_server_rpm_download_link="$mysql_repo_url/MySQL-$mysql_version/mysql-community-server-$mysql_sub_version.$system_version.x86_64.rpm"
mysql_common_rpm_download_link="$mysql_repo_url/MySQL-$mysql_version/mysql-community-common-$mysql_sub_version.$system_version.x86_64.rpm"
mysql_client_rpm_download_link="$mysql_repo_url/MySQL-$mysql_version/mysql-community-client-$mysql_sub_version.$system_version.x86_64.rpm"
mysql_client_plugins_rpm_download_link="$mysql_repo_url/MySQL-$mysql_version/mysql-community-client-plugins-$mysql_sub_version.$system_version.x86_64.rpm"
mysql_libs_rpm_download_link="$mysql_repo_url/MySQL-$mysql_version/mysql-community-libs-$mysql_sub_version.$system_version.x86_64.rpm"

if [ "x86_64" == "$system_arch" ]; then
    echo "The system arch is x86_64"
else
    echo "The system arch is $system_arch"
    mysql_server_rpm_download_link="$mysql_repo_url/MySQL-$mysql_version/mysql-community-server-$mysql_sub_version.$system_version.aarch64.rpm"
    mysql_common_rpm_download_link="$mysql_repo_url/MySQL-$mysql_version/mysql-community-common-$mysql_sub_version.$system_version.aarch64.rpm"
    mysql_client_rpm_download_link="$mysql_repo_url/MySQL-$mysql_version/mysql-community-client-$mysql_sub_version.$system_version.aarch64.rpm"
    mysql_client_plugins_rpm_download_link="$mysql_repo_url/MySQL-$mysql_version/mysql-community-client-plugins-$mysql_sub_version.$system_version.aarch64.rpm"
    mysql_libs_rpm_download_link="$mysql_repo_url/MySQL-$mysql_version/mysql-community-libs-$mysql_sub_version.$system_version.aarch64.rpm"
fi