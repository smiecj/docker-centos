# java install envs

## AdoptOpenJDK => Adoptium
### refer: https://mirrors.tuna.tsinghua.edu.cn/news/rename-adoptopenjdk-to-adoptium/
### refer: https://felord.cn/adoptopenjdk-join-eclipse-foundation.html

system_arch=`uname -p`
### default pkg download url is base on X86_64
jdk_11_repo="https://mirrors.tuna.tsinghua.edu.cn/Adoptium/11/jdk/x64/linux"
jdk_11_pkg=`curl -L $jdk_11_repo | grep OpenJDK11U | grep hotspot | sed 's/.*title="//g' | sed 's/".*//g'`
jdk_11_download_url=$jdk_11_repo/$jdk_11_pkg
jdk_11_detail_version=`echo $jdk_11_pkg | sed 's/.*hotspot_11/11/g' | sed 's/.tar.*//g' | tr '_' '+'`
jdk_11_folder="jdk-$jdk_11_detail_version"

jdk_8_repo="https://mirrors.tuna.tsinghua.edu.cn/Adoptium/8/jdk/x64/linux"
jdk_8_pkg=`curl -L $jdk_8_repo | grep OpenJDK8U | grep hotspot | sed 's/.*title="//g' | sed 's/".*//g'`
jdk_8_download_url=$jdk_8_repo/$jdk_8_pkg
jdk_8_detail_version=`echo $jdk_8_pkg | sed 's/.*hotspot_8/8/g' | sed 's/.tar.*//g' | sed 's/b/-b/g'`
jdk_8_folder="jdk$jdk_8_detail_version"

if [ "x86_64" == "$system_arch" ]; then
    echo "The system arch is x86_64"
else
    jdk_11_repo="https://mirrors.tuna.tsinghua.edu.cn/Adoptium/11/jdk/aarch64/linux"
    jdk_11_pkg=`curl -L $jdk_11_repo | grep OpenJDK11U | grep hotspot | sed 's/.*title="//g' | sed 's/".*//g'`
    jdk_11_download_url=$jdk_11_repo/$jdk_11_pkg
    jdk_11_detail_version=`echo $jdk_11_pkg | sed 's/.*hotspot_11/11/g' | sed 's/.tar.*//g' | tr '_' '+'`
    jdk_11_folder="jdk-$jdk_11_detail_version"

    jdk_8_repo="https://mirrors.tuna.tsinghua.edu.cn/Adoptium/8/jdk/aarch64/linux"
    jdk_8_pkg=`curl -L $jdk_8_repo | grep OpenJDK8U | grep hotspot | sed 's/.*title="//g' | sed 's/".*//g'`
    jdk_8_download_url=$jdk_8_repo/$jdk_8_pkg
    jdk_8_detail_version=`echo $jdk_8_pkg | sed 's/.*hotspot_8/8/g' | sed 's/.tar.*//g' | sed 's/b/-b/g'`
    jdk_8_folder="jdk$jdk_8_detail_version"
fi