FROM centos_base AS base

MAINTAINER smiecj smiecj@github.com

USER root

# buildkit
ARG TARGETARCH

# install rust

ARG CARGO_HOME=/usr/rust
ARG RUSTUP_HOME=/home/repo/rust

ARG rust_version=1.25.1
# https://static.rust-lang.org/dist/rust-1.62.1-aarch64-unknown-linux-gnu.tar.gz

RUN mkdir -p $CARGO_HOME && mkdir -p $RUSTUP_HOME

RUN if [ "arm64" == "${TARGETARCH}" ]; then arch="aarch64"; else arch="x86_64"; fi && \
    rust_up_download_url=https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup/archive/${rust_version}/${arch}-unknown-linux-gnu/rustup-init && \
    cd /tmp && curl -LO ${rust_up_download_url} && chmod +x rustup-init && ./rustup-init -y && \
    rm rustup-init

RUN echo -e """\n# rust\n\
export CARGO_HOME=$CARGO_HOME\n\
export PATH=\$PATH:\$CARGO_HOME/bin\n\
""" >> /etc/profile

## install toolchain
RUN source /etc/profile && rustup default stable