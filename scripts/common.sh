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

    ### gcc & make
    yum -y install make
    yum -y install gcc
    yum -y install gcc-c++
    yum -y install cmake

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
    yum -y install libxml2 libxml2-devel
    yum -y install libxslt libxslt-devel
}

## add systemd service (use nohup to start)
add_systemd_service() {
    local service=$1
    local path=$2
    local env=$3
    local start_script=$4
    local stop_script=$5
    local need_enable="false"
    if [ $# -eq 6 ]; then
        need_enable=$6
    fi
    
    systemd_file_path=/etc/systemd/system/$service.service
    cat > $systemd_file_path << EOF
# $service systemd
## $systemd_file_path

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

    if [ "true" == $need_enable ]; then
        ln -s /usr/lib/systemd/system/$service.service /etc/systemd/system/multi-user.target.wants/$service.service || true
    fi
}

## write logrotate file
add_logrorate_task() {
    local log_path=$1
    local log_name=$2
    local rotate_conf=/etc/logrotate.d/$log_name
    echo "$log_path{" > $rotate_conf
    echo "    copytruncate" >> $rotate_conf
    echo "    daily" >> $rotate_conf
    echo "    rotate 7" >> $rotate_conf
    echo "    missingok" >> $rotate_conf
    echo "    compress" >> $rotate_conf
    echo "    size 200M" >> $rotate_conf
    echo "}" >> $rotate_conf
}