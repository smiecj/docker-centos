#!/bin/bash
sftp_group_name=sftp_users
sftp_test_user_name=test_user
sftp_test_user_pwd=testuser
sftp_data_home=/opt/sftp_data

# create sftp test user
groupadd $sftp_group_name
useradd -g $sftp_group_name -d /upload -s /sbin/nologin $sftp_test_user_name
echo $sftp_test_user_name:$sftp_test_user_pwd | chpasswd

# add sshd config
echo -e """\
Match Group $sftp_group_name\n\
ChrootDirectory $sftp_data_home/%u\n\
ForceCommand internal-sftp\n\
""" >> /etc/ssh/sshd_config

# create sftp data home and test user folder
mkdir -p $sftp_data_home
mkdir -p $sftp_data_home/$sftp_test_user_name/upload
chown -R root:$sftp_group_name $sftp_data_home
chown -R $sftp_test_user_name:$sftp_group_name $sftp_data_home/$sftp_test_user_name/upload

# remote nologin script
rm -f /var/run/nologin
