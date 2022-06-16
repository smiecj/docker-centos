## python install envs

### github link: https://github.com/conda-forge/miniforge/releases/download/4.12.0-0/Miniforge3-4.12.0-0-Linux-x86_64.sh
conda_repo_home_url=https://mirrors.tuna.tsinghua.edu.cn/github-release/conda-forge/miniforge
conda_forge_version=`curl -L $conda_repo_home_url | grep Miniforge3 | sed 's/.*title="//g' | sed 's/".*//g'`

conda_forge_download_url=https://mirrors.tuna.tsinghua.edu.cn/github-release/conda-forge/miniforge/$conda_forge_version/$conda_forge_version-Linux-x86_64.sh

system_arch=`uname -p`
if [[ "aarch64" == "$system_arch" ]]; then
    ### arm
    conda_forge_download_url=https://mirrors.tuna.tsinghua.edu.cn/github-release/conda-forge/miniforge/$conda_forge_version/$conda_forge_version-Linux-aarch64.sh
fi
