#!/bin/bash
set -euxo pipefail

# 获取镜像初始化参数
root_pwd="root!centos123"
if [[ $# -gt 0 ]]; then
    root_pwd=$1
fi

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ./common.sh

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
    ### centos7 需要区分不同的操作系统
    ### 参考: https://blog.csdn.net/smart9527_zc/article/details/84976097
    system_arch=`uname -p`
    if [ "x86_64" == "$system_arch" ]; then
        mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.bak_repo
        curl -Lo /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
    elif [ "aarch64" == "$system_arch" ]; then
        ### vault 源统一使用 清华源
        sed -i -e "s|mirrorlist=|#mirrorlist=|g" /etc/yum.repos.d/CentOS-*
        sed -i -e "s|#baseurl=http://mirror.centos.org|baseurl=http://mirrors.tuna.tsinghua.edu.cn/centos-vault|g" /etc/yum.repos.d/CentOS-*
    fi
fi
yum clean all
yum makecache

## install centos basic tools
install_basic_tools

## bashrc
sed -i "s/alias cp/#alias cp/g" ~/.bashrc
sed -i "s/alias mv/#alias mv/g" ~/.bashrc
echo "alias ll='ls -l'" >> ~/.bashrc
echo "alias rm='rm -f'" >> ~/.bashrc

## zsh
rm -rf /root/.oh-my-zsh
yum -y install zsh \
    && echo Y | sh -c "$(curl -fsSL https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh)"

yum -y install util-linux-user || true
chsh -s /bin/zsh

### plugin: autosuggestions
git clone https://gitee.com/atamagaii/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

### plugin: syntax highlighting
git clone https://gitee.com/atamagaii/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

sed -i 's/$plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' ~/.zshrc
echo '' >> ~/.zshrc
echo 'source /etc/profile' >> ~/.zshrc

## vim support utf-8
echo "set encoding=utf-8 fileencodings=ucs-bom,utf-8,cp936" >> ~/.vimrc

## set login password
echo root:$root_pwd | chpasswd

#exec /usr/sbin/init

popd