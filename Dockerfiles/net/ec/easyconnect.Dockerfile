ARG IMAGE_XRDP
FROM ${IMAGE_XRDP}

ARG module_home
ARG github_url

ARG easyconnect_version=7.6.7.3
ARG clash_version=v1.10.6
ARG firefox_version=101.0
# ARG firefox_mirror="https://download-installer.cdn.mozilla.net"
ARG firefox_mirror="https://ftp.mozilla.org"

# clash
ARG clash_folder=${module_home}/clash

RUN clash_pkg=clash-linux-amd64-${clash_version}.gz && \
    clash_bin=clash-linux-amd64-${clash_version} && \
    clash_pkg_url=${github_url}/Dreamacro/clash/releases/download/${clash_version}/${clash_pkg} && \
    clash_country_db_url=${github_url}/Dreamacro/maxmind-geoip/releases/download/20230712/Country.mmdb && \

    mkdir -p ${clash_folder} && cd ${clash_folder} && curl -LO ${clash_pkg_url} && \
    gzip -d ${clash_pkg} && mv ${clash_bin} clash && chmod +x clash && \
    cd ${clash_folder} && curl -LO ${clash_country_db_url} && \

## start when reboot(crond)
    yum -y install cronie && systemctl enable crond && \
    echo "@reboot nohup ${clash_folder}/clash -d ${clash_folder} > /dev/null 2>&1 &" >> /var/spool/cron/root && \

## config
COPY ./config.yaml ${clash_folder}/config.yaml

# easyconnect
RUN easyconnect_version=`echo ${easyconnect_version} | sed "s/\./_/g"` && \
    ec_pkg=EasyConnect_x64_${easyconnect_version}.rpm && \
    ec_pkg_url=http://download.sangfor.com.cn/download/product/sslvpn/pkg/linux_767/${ec_pkg} && \

## install
    cd /tmp && curl -LO ${ec_pkg_url} && rpm -ivh ${ec_pkg} && rm ${ec_pkg} && \

## temporary close ECAgent process to avoid memory leak
## backup /etc/hosts
    echo "*/10 * * * * ps -ef | grep ECAgent | grep -v grep | awk '{print \$2}' | xargs --no-run-if-empty kill -9" >> /var/spool/cron/root && \
    echo "@reboot cat /etc/hosts_bak > /etc/hosts" >> /var/spool/cron/root && \
    echo "0 */1 * * * cat /etc/hosts > /etc/hosts_bak" && \

# firefox
    firefox_pkg=firefox-${firefox_version}.tar.bz2 && \
    firefox_pkg_url=${firefox_mirror}/pub/firefox/releases/${firefox_version}/linux-x86_64/en-US/${firefox_pkg} && \

    yum -y install bzip2 && \
    mkdir -p ${module_home} && cd ${module_home} && curl -LO ${firefox_pkg_url} && \
    tar -jxvf ${firefox_pkg} && rm ${firefox_pkg} && \

## soft link to desktop
    mkdir -p ${HOME}/Desktop && ln -s ${module_home}/firefox/firefox ${HOME}/Desktop/firefox && \
    ln -s /usr/share/sangfor/EasyConnect/EasyConnect ${HOME}/Desktop/EasyConnect
