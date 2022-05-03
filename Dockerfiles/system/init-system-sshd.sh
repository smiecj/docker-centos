#!/bin/bash

# install sshd and set s6 run script
## install if needed

## generate key
ssh-keygen -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N ""
ssh-keygen -t ecdsa -b 256 -f /etc/ssh/ssh_host_ecdsa_key -N ""
ssh-keygen -t ed25519 -b 256 -f /etc/ssh/ssh_host_ed25519_key -N ""

## s6 script
sshd_s6_home=/etc/services.d/sshd
mkdir -p $sshd_s6_home
. /etc/crypto-policies/back-ends/opensshserver.config && . /etc/sysconfig/sshd && echo "/usr/sbin/sshd -D $OPTIONS $CRYPTO_POLICY" > $sshd_s6_home/run
