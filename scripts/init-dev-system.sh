#!/bin/bash
#set -euxo pipefail

# install centos develop system
docker_centos_repo_home=/home/coding/docker-centos-main

. ./env_system.sh

## judge system architecture and decide some variable value
system_arch=`uname -p`
### default pkg download url is base on X86_64
jdk_11_download_url=https://mirrors.tuna.tsinghua.edu.cn/AdoptOpenJDK/11/jdk/x64/linux/OpenJDK11U-jdk_x64_linux_hotspot_11.0.13_8.tar.gz
jdk_11_folder=jdk-11.0.13+8
jdk_11_pkg=`echo $jdk_11_download_url | sed 's/.*\///g'`

jdk_8_download_url=https://mirrors.tuna.tsinghua.edu.cn/AdoptOpenJDK/8/jdk/x64/linux/OpenJDK8U-jdk_x64_linux_hotspot_8u312b07.tar.gz
jdk_8_pkg=`echo $jdk_8_download_url | sed 's/.*\///g'`
jdk_8_folder=jdk8u312-b07

maven_download_url=https://dlcdn.apache.org/maven/maven-3/3.8.4/binaries/apache-maven-3.8.4-bin.tar.gz
maven_pkg=`echo $maven_download_url | sed 's/.*\///g'`
maven_version=3.8.4
gradle_download_url=https://services.gradle.org/distributions/gradle-7.0.2-bin.zip
gradle_pkg=`echo $gradle_download_url | sed 's/.*\///g'`
gradle_version=7.0.2
go_download_url=https://go.dev/dl/go1.17.5.linux-amd64.tar.gz
go_pkg=`echo $go_download_url | sed 's/.*\///g'`

if [ "x86_64" == "$system_arch" ]; then
    echo "The system arch is x86_64"
else
    jdk_11_download_url=https://mirrors.tuna.tsinghua.edu.cn/AdoptOpenJDK/11/jdk/aarch64/linux/OpenJDK11U-jdk_aarch64_linux_openj9_linuxXL_11.0.10_9_openj9-0.24.0.tar.gz
    jdk_11_pkg=`echo $jdk_11_download_url | sed 's/.*\///g'`
    jdk_11_folder=jdk-11.0.13+9
    jdk_8_download_url=https://mirrors.tuna.tsinghua.edu.cn/AdoptOpenJDK/8/jdk/aarch64/linux/OpenJDK8U-jdk_aarch64_linux_hotspot_8u312b07.tar.gz
    jdk_8_pkg=`echo $jdk_8_download_url | sed 's/.*\///g'`
    jdk_8_folder=jdk8u312-b07
    go_download_url=https://go.dev/dl/go1.17.4.linux-arm64.tar.gz
    go_pkg=`echo $go_download_url | sed 's/.*\///g'`
fi

## java install (openjdk)
java_home=/usr/java
mkdir -p $java_home
mkdir -p $repo_home/java
pushd $java_home
rm -rf *

curl -LO $jdk_11_download_url
tar -xzvf $jdk_11_pkg
rm -f $jdk_11_pkg

curl -LO $jdk_8_download_url
tar -xzvf $jdk_8_pkg
rm -f $jdk_8_pkg

### maven
curl -LO $maven_download_url
tar -xzvf $maven_pkg
rm -f $maven_pkg

maven_home=/usr/java/apache-maven-$maven_version
maven_repo=$repo_home/java/maven
maven_repo_replace_str=$(echo "$maven_repo" | sed 's/\//\\\//g')
cp -f $docker_centos_repo_home/components/maven/settings.xml $maven_home/conf
sed -i "s/maven_local_repo/$maven_repo_replace_str/g" $maven_home/conf/settings.xml
rm -rf ~/.m2/repository && ln -s $maven_repo ~/.m2/repository

### gradle
curl -LO $gradle_download_url
unzip $gradle_pkg
rm -f $gradle_pkg

### java environment
echo -e '\n# java' >> /etc/profile
echo "export JAVA_HOME=$java_home/$jdk_8_folder" >> /etc/profile
echo "export JRE_HOME=$java_home/$jdk_8_folder/jre" >> /etc/profile
echo 'export CLASS_PATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib' >> /etc/profile
echo "export MAVEN_HOME=" >> /etc/profile
echo "export GRADLE_HOME=/usr/java/gradle-$gradle_version" >> /etc/profile
echo "export GRADLE_USER_HOME=$repo_home/java/gradle" >> /etc/profile
echo "export JDK_HOME=$java_home/$jdk_11_folder" >> /etc/profile

popd

## golang install
go_home=/usr/golang
go_repo_home=$repo_home/go
mkdir -p $go_home
mkdir -p $go_repo_home
pushd $go_home
rm -rf *
curl -LO $go_download_url
tar -xzvf $go_pkg
rm -f $go_pkg

### golang environment
echo -e '\n# go' >> /etc/profile
echo "export GOROOT=$go_home/go" >> /etc/profile
echo "export GOPATH=$go_repo_home" >> /etc/profile

popd

## npm install
sh ./init-system-node.sh

## python install
pushd /tmp
rm -f main.zip
rm -rf python-tools-main
curl -LO https://github.com/smiecj/python-tools/archive/refs/heads/main.zip
unzip main.zip
pushd python-tools-main
make install_conda
popd
rm -rf python-tools-main
rm -f main.zip
popd

### python environment
echo 'export PYTHON3_HOME=/usr/local/miniconda/envs/py3' >> /etc/profile

## bin PATH
echo "" >> /etc/profile
echo 'export PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin:$MAVEN_HOME/bin:$GRADLE_HOME/bin:$GOROOT/bin:$GOPATH/bin:$NODE_REPO/bin:$PYTHON3_HOME/bin' >> /etc/profile

### check all develop environment have installed
source /etc/profile && go version && java -version && npm -v && node -v && $CONDA_HOME/envs/py3/bin/python3 -V

## vim support utf-8
echo "set encoding=utf-8 fileencodings=ucs-bom,utf-8,cp936" >> ~/.vimrc

## ulimit: max open files
echo -e "* soft nofile 100001\n* hard nofile 100002" >> /etc/security/limits.conf

## clean history
history -c

## timezone
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
