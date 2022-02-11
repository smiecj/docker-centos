# install some basic tools when use developing
install_basic_tools() {
    ### initscripts refer: https://yum-info.contradodigital.com/view-package/installed/initscripts/
    yum -y install initscripts

    ### some compile basic package
    yum -y install libncurses* libaio numactl

    ### sshd
    yum -y install openssh-server openssh-clients openssl openssl-devel compat-openssl10
    systemctl enable sshd

    ### gcc
    yum -y install gcc
    yum -y install gcc-c++

    ### other useful tools
    yum -y install lsof net-tools vim lrzsz zip unzip bzip2 ncurses git wget make sudo passwd cronie
    yum -y install expect epel-release jq
}