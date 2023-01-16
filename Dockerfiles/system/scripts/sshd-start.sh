#!/bin/bash

## init ssh
if [ ! -f "/etc/ssh/ssh_host_rsa_key" ]; then
    ssh-keygen -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N ""
    ssh-keygen -t ecdsa -b 256 -f /etc/ssh/ssh_host_ecdsa_key -N ""
    ssh-keygen -t ed25519 -b 256 -f /etc/ssh/ssh_host_ed25519_key -N ""
fi

## start sshd
nohup /usr/sbin/sshd -D $OPTIONS $CRYPTO_POLICY > /dev/null 2>&1 &
