ARG MINIMAL_IMAGE_7
FROM ${MINIMAL_IMAGE_7}

ENV repo_home

# install git
RUN yum -y install git && \

# add user git
    useradd git && \

# init empty repo
    mkdir -p ${repo_home} && chown git:git ${repo_home} && \
    su - git -s /bin/bash -c "cd ${repo_home} && git init --bare sample.git && ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa" && \

# sshd
## install sshd
    yum -y install openssh-server openssh-clients openssl openssl-devel compat-openssl10 && \
    ssh-keygen -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N "" && \
    ssh-keygen -t ecdsa -b 256 -f /etc/ssh/ssh_host_ecdsa_key -N "" && \
    ssh-keygen -t ed25519 -b 256 -f /etc/ssh/ssh_host_ed25519_key -N "" && \

## sshd s6 script
    sshd_s6_home=/etc/services.d/sshd
    mkdir -p ${sshd_s6_home} && \
    echo '#!/bin/bash' > ${sshd_s6_home}/run && \
    . /etc/sysconfig/sshd && \
    echo "/usr/sbin/sshd -D $OPTIONS $CRYPTO_POLICY" >> ${sshd_s6_home}/run && \

# git shell set git-shell
    sed -i "s#git:/bin/bash#git:/usr/bin/git-shell#g" /etc/passwd

# config ssh : cat "public_key" >> /home/git/.ssh/authorized_keys

# test: git clone git@server:${repo_home}/sample.git