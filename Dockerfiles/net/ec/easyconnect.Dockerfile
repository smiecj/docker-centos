FROM centos_xrdp

ARG module_home=/home/modules

# clash
ARG clash_pkg_url=https://github.com/Dreamacro/clash/releases/download/v1.10.6/clash-linux-amd64-v1.10.6.gz
ARG clash_country_db_url=https://cdn.jsdelivr.net/gh/Dreamacro/maxmind-geoip@release/Country.mmdb
ARG clash_pkg=clash-linux-amd64-v1.10.6.gz
ARG clash_bin=clash-linux-amd64-v1.10.6
ARG clash_folder=${module_home}/clash

RUN mkdir -p ${clash_folder} && cd ${clash_folder} && curl -LO ${clash_pkg_url} && \
    gzip -d ${clash_pkg} && mv ${clash_bin} clash && chmod +x clash
RUN cd ${clash_folder} && curl -LO ${clash_country_db_url}

## config
COPY ./clash_config.yaml ${clash_folder}/

## start when reboot(crond)
RUN yum -y install cronie && systemctl enable crond
RUN echo "@reboot nohup ${clash_folder}/clash -d ${clash_folder} > /dev/null 2>&1 &" >> /var/spool/cron/root

# easyconnect
ARG ec_pkg_url=http://download.sangfor.com.cn/download/product/sslvpn/pkg/linux_767/EasyConnect_x64_7_6_7_3.rpm
ARG ec_pkg=EasyConnect_x64_7_6_7_3.rpm

## install
RUN cd /tmp && curl -LO ${ec_pkg_url} && rpm -ivh ${ec_pkg} && rm ${ec_pkg}

## temporary close ECAgent process to avoid memory leak
RUN echo "*/10 * * * * ps -ef | grep ECAgent | grep -v grep | awk '{print $2}' | xargs --no-run-if-empty kill -9" >> /var/spool/cron/root

# firefox
ARG firefox_pkg_url=https://download-installer.cdn.mozilla.net/pub/firefox/releases/101.0/linux-x86_64/en-US/firefox-101.0.tar.bz2
ARG firefox_pkg=firefox-101.0.tar.bz2
ARG firefox_folder=firefox
RUN yum -y install bzip2
RUN mkdir -p ${module_home} && cd ${module_home} && curl -LO ${firefox_pkg_url} && \
    tar -jxvf ${firefox_pkg} && rm ${firefox_pkg}

## soft link to desktop
RUN ln -s ${module_home}/${firefox_folder}/firefox ${HOME}/Desktop/firefox
