# install some basic tools when use developing
install_basic_tools() {
    ### epel refer: https://docs.fedoraproject.org/en-US/epel/
    yum -y install epel-release

    ### initscripts refer: https://yum-info.contradodigital.com/view-package/installed/initscripts/
    yum -y install initscripts

    ### some compile basic package
    yum -y install libncurses* libaio numactl

    ### sshd
    yum -y install openssh-server openssh-clients openssl openssl-devel compat-openssl10
    #systemctl enable sshd

    ### gcc
    yum -y install make
    yum -y install gcc
    yum -y install gcc-c++

    ### other useful tools
    yum -y install lsof net-tools vim lrzsz zip unzip bzip2 ncurses git wget sudo passwd cronie
    yum -y install expect jq telnet net-tools rsync

    #### git config
    git config --global pull.rebase false

    ### devel pkg
    yum -y install cyrus-sasl cyrus-sasl-devel
    yum -y install python3-devel
    yum -y install libffi-devel
    yum -y install freetds-devel
    yum -y install mysql-devel unixODBC-devel
}