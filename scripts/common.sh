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

## add systemd service (use nohup to start)
add_systemd_service() {
    local service=$1
    local path=$2
    local env=$3
    local start_script=$4
    local stop_script=$5
    
    cat > /etc/systemd/system/$service.service << EOF
# $service systemd
## /etc/systemd/system/$service.service

[Unit]
Description=$service
After=
Wants=

[Service]
Environment="PATH=$path"
Environment="$env"
Type=oneshot
ExecStart=$start_script
ExecStop=$stop_script
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
}