#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ./env_system.sh

system_arch=`uname -p`
### default pkg download url is base on X86_64
## 当前: 更改逻辑，需要先确认当前仓库最新的 JDK 版本，并设置 folder 这些信息
jdk_11_repo="https://mirrors.tuna.tsinghua.edu.cn/AdoptOpenJDK/11/jdk/x64/linux"
jdk_11_pkg=`curl -L $jdk_11_repo | grep OpenJDK11U | grep hotspot | sed 's/.*title="//g' | sed 's/".*//g'`
jdk_11_download_url=$jdk_11_repo/$jdk_11_pkg
jdk_11_detail_version=`echo $jdk_11_pkg | sed 's/.*hotspot_11/11/g' | sed 's/.tar.*//g' | tr '_' '+'`
jdk_11_folder="jdk-$jdk_11_detail_version"

jdk_8_repo="https://mirrors.tuna.tsinghua.edu.cn/AdoptOpenJDK/8/jdk/x64/linux"
jdk_8_pkg=`curl -L $jdk_8_repo | grep OpenJDK8U | grep hotspot | sed 's/.*title="//g' | sed 's/".*//g'`
jdk_8_download_url=$jdk_8_repo/$jdk_8_pkg
jdk_8_detail_version=`echo $jdk_8_pkg | sed 's/.*hotspot_8/8/g' | sed 's/.tar.*//g' | sed 's/b/-b/g'`
jdk_8_folder="jdk$jdk_8_detail_version"

maven_download_url=https://dlcdn.apache.org/maven/maven-3/3.8.4/binaries/apache-maven-3.8.4-bin.tar.gz
maven_pkg=`echo $maven_download_url | sed 's/.*\///g'`
maven_version=3.8.4
gradle_download_url=https://services.gradle.org/distributions/gradle-7.0.2-bin.zip
gradle_pkg=`echo $gradle_download_url | sed 's/.*\///g'`
gradle_version=7.0.2
if [ "x86_64" == "$system_arch" ]; then
    echo "The system arch is x86_64"
else
    jdk_11_repo="https://mirrors.tuna.tsinghua.edu.cn/AdoptOpenJDK/11/jdk/aarch64/linux"
    jdk_11_pkg=`curl -L $jdk_11_repo | grep OpenJDK11U | grep hotspot | sed 's/.*title="//g' | sed 's/".*//g'`
    jdk_11_download_url=$jdk_11_repo/$jdk_11_pkg
    jdk_11_detail_version=`echo $jdk_11_pkg | sed 's/.*hotspot_11/11/g' | sed 's/.tar.*//g' | tr '_' '+'`
    jdk_11_folder="jdk-$jdk_11_detail_version"

    jdk_8_repo="https://mirrors.tuna.tsinghua.edu.cn/AdoptOpenJDK/8/jdk/aarch64/linux"
    jdk_8_pkg=`curl -L $jdk_8_repo | grep OpenJDK8U | grep hotspot | sed 's/.*title="//g' | sed 's/".*//g'`
    jdk_8_download_url=$jdk_8_repo/$jdk_8_pkg
    jdk_8_detail_version=`echo $jdk_8_pkg | sed 's/.*hotspot_8/8/g' | sed 's/.tar.*//g' | sed 's/b/-b/g'`
    jdk_8_folder="jdk$jdk_8_detail_version"
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
cp -f $home_path/../components/maven/settings.xml $maven_home/conf
sed -i "s/maven_local_repo/$maven_repo_replace_str/g" $maven_home/conf/settings.xml
default_maven_repo_path=~/.m2/repository
rm -rf $default_maven_repo_path && mkdir -p $default_maven_repo_path && ln -s $maven_repo $default_maven_repo_path

### gradle
curl -LO $gradle_download_url
unzip $gradle_pkg
rm -f $gradle_pkg

### java environment
echo -e '\n# java' >> /etc/profile
echo "export JAVA_HOME=$java_home/$jdk_8_folder" >> /etc/profile
echo 'export JRE_HOME=$JAVA_HOME/jre' >> /etc/profile
echo 'export CLASS_PATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib' >> /etc/profile
echo "export MAVEN_HOME=$maven_home" >> /etc/profile
echo "export GRADLE_HOME=/usr/java/gradle-$gradle_version" >> /etc/profile
echo "export GRADLE_USER_HOME=$repo_home/java/gradle" >> /etc/profile
echo "export JDK_HOME=$java_home/$jdk_11_folder" >> /etc/profile
echo 'export PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin:$MAVEN_HOME/bin:$GRADLE_HOME/bin' >> /etc/profile

popd

popd