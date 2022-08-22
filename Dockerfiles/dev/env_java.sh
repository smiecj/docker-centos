# java install envs

## AdoptOpenJDK => Adoptium
### refer: https://mirrors.tuna.tsinghua.edu.cn/news/rename-adoptopenjdk-to-adoptium/
### refer: https://felord.cn/adoptopenjdk-join-eclipse-foundation.html

jdk_new_version=$1

system_arch=`uname -p`
### default pkg download url is base on X86_64
jdk_new_version_repo="https://mirrors.tuna.tsinghua.edu.cn/Adoptium/${jdk_new_version}/jdk/x64/linux"
jdk_new_version_pkg=`curl -L $jdk_new_version_repo | grep OpenJDK${jdk_new_version}U | grep hotspot | sed 's/.*title="//g' | sed 's/".*//g'`
jdk_new_version_download_url=$jdk_new_version_repo/$jdk_new_version_pkg
jdk_new_version_detail_version=`echo $jdk_new_version_pkg | sed "s/.*hotspot_${jdk_new_version}/${jdk_new_version}/g" | sed 's/.tar.*//g' | tr '_' '+'`
jdk_new_version_folder="jdk-$jdk_new_version_detail_version"

jdk_8_repo="https://mirrors.tuna.tsinghua.edu.cn/Adoptium/8/jdk/x64/linux"
jdk_8_pkg=`curl -L $jdk_8_repo | grep OpenJDK8U | grep hotspot | sed 's/.*title="//g' | sed 's/".*//g'`
jdk_8_download_url=$jdk_8_repo/$jdk_8_pkg
jdk_8_detail_version=`echo $jdk_8_pkg | sed 's/.*hotspot_8/8/g' | sed 's/.tar.*//g' | sed 's/b/-b/g'`
jdk_8_folder="jdk$jdk_8_detail_version"

if [ "x86_64" == "$system_arch" ]; then
    echo "The system arch is x86_64"
else
    jdk_new_version_repo="https://mirrors.tuna.tsinghua.edu.cn/Adoptium/${jdk_new_version}/jdk/aarch64/linux"
    jdk_new_version_pkg=`curl -L $jdk_new_version_repo | grep OpenJDK${jdk_new_version}U | grep hotspot | sed 's/.*title="//g' | sed 's/".*//g'`
    jdk_new_version_download_url=$jdk_new_version_repo/$jdk_new_version_pkg
    jdk_new_version_detail_version=`echo $jdk_new_version_pkg | sed "s/.*hotspot_${jdk_new_version}/${jdk_new_version}/g" | sed 's/.tar.*//g' | tr '_' '+'`
    jdk_new_version_folder="jdk-$jdk_new_version_detail_version"

    jdk_8_repo="https://mirrors.tuna.tsinghua.edu.cn/Adoptium/8/jdk/aarch64/linux"
    jdk_8_pkg=`curl -L $jdk_8_repo | grep OpenJDK8U | grep hotspot | sed 's/.*title="//g' | sed 's/".*//g'`
    jdk_8_download_url=$jdk_8_repo/$jdk_8_pkg
    jdk_8_detail_version=`echo $jdk_8_pkg | sed 's/.*hotspot_8/8/g' | sed 's/.tar.*//g' | sed 's/b/-b/g'`
    jdk_8_folder="jdk$jdk_8_detail_version"
fi
