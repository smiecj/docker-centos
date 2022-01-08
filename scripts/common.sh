# install some basic tools when use developing
install_basic_tools() {
    ### initscripts refer: https://yum-info.contradodigital.com/view-package/installed/initscripts/
    yum -y install initscripts

    ### sshd
    yum -y install openssh-server openssh-clients
    systemctl enable sshd

    ### gcc
    yum -y install gcc
    yum -y install gcc-c++

    ### other useful tools
    yum -y install lsof net-tools vim lrzsz zip ncurses git wget make sudo passwd
    yum -y install expect epel-release jq
}