#!/bin/bash
set -euxo pipefail

## yum 源修复或加速
centos_version=`cat /etc/redhat-release | sed 's/.*release //g' | sed 's/ .*//g'`
if [[ $centos_version =~ 8.* ]]; then
    ### centos8 参考: https://programmerah.com/centos-8-no-urls-in-mirrorlist-error-how-to-solve-48945/
    #### 国内源有无法访问 或者 依赖补全（比如腾讯源没有 gcc），先注释，vault 使用国内的清华源
    # mv /etc/yum.repos.d/CentOS-Linux-AppStream.repo /etc/yum.repos.d/CentOS-Linux-AppStream.bak_repo
    # cp ../components/yum/CentOS-Linux-AppStream.repo /etc/yum.repos.d/CentOS-Linux-AppStream.repo
    # mv /etc/yum.repos.d/CentOS-Linux-BaseOS.repo /etc/yum.repos.d/CentOS-Linux-BaseOS.bak_repo
    # curl -Lo /etc/yum.repos.d/CentOS-Linux-BaseOS.repo http://mirrors.cloud.tencent.com/repo/centos8_base.repo
    sed -i -e "s|mirrorlist=|#mirrorlist=|g" /etc/yum.repos.d/CentOS-*
    # sed -i -e "s|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g" /etc/yum.repos.d/CentOS-*
    sed -i -e "s|#baseurl=http://mirror.centos.org|baseurl=http://mirrors.tuna.tsinghua.edu.cn/centos-vault|g" /etc/yum.repos.d/CentOS-*
elif [[ $centos_version =~ 7.* ]]; then
    ### centos7: https://mirrors.tuna.tsinghua.edu.cn/help/centos/
    system_arch=`uname -p`
    if [ "x86_64" == "$system_arch" ]; then
        sed -e 's|^mirrorlist=|#mirrorlist=|g' \
                -e 's|^#baseurl=http://mirror.centos.org|baseurl=https://mirrors.tuna.tsinghua.edu.cn|g' \
                -i.bak \
                /etc/yum.repos.d/CentOS-*.repo
    elif [[ "aarch64" == "$system_arch" ]]; then
        mv -f /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.bak_repo
        cp -f /tmp/yum/CentOS-7-epel.repo /etc/yum.repos.d/epel.repo
        cp -f /tmp/yum/CentOS-7-Base.repo /etc/yum.repos.d/CentOS-Base.repo
        cp -f /tmp/yum/RPM-GPG-KEY-CentOS-7 /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
        cp -f /tmp/yum/RPM-GPG-KEY-CentOS-7-aarch64 /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7-aarch64
        cp -f /tmp/yum/RPM-GPG-KEY-EPEL-7 /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
        rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7-aarch64
        rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
    fi
fi

yum clean all
yum makecache

if [[ $centos_version =~ 8.* ]]; then
    ### fix: Unexpected key in data: static_context
    dnf -y update libmodulemd
fi