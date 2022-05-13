## python install envs

conda_forge_download_url=https://mirrors.tuna.tsinghua.edu.cn/github-release/conda-forge/miniforge/Miniforge3-$conda_forge_version/Miniforge3-$conda_forge_version-Linux-x86_64.sh

system_arch=`uname -p`
if [[ "aarch64" == "$system_arch" ]]; then
    ### arm
    conda_forge_download_url=https://mirrors.tuna.tsinghua.edu.cn/github-release/conda-forge/miniforge/Miniforge3-$conda_forge_version/Miniforge3-$conda_forge_version-Linux-aarch64.sh
fi
