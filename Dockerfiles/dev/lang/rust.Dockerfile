ARG IMAGE_BASE
FROM ${IMAGE_BASE} AS base

USER root

# buildkit
ARG TARGETARCH

# install rust

ARG CARGO_HOME=/usr/rust
ARG repo_home
ARG RUSTUP_HOME=${repo_home}/rust

ARG RUST_VERSION
ARG rust_repo

RUN mkdir -p $CARGO_HOME && mkdir -p $RUSTUP_HOME && \
    if [ "arm64" == "${TARGETARCH}" ]; then arch="aarch64"; else arch="x86_64"; fi && \
    rust_up_download_url=${rust_repo}/${RUST_VERSION}/${arch}-unknown-linux-gnu/rustup-init && \
    cd /tmp && curl -LO ${rust_up_download_url} && chmod +x rustup-init && ./rustup-init -y && \
    rm rustup-init && \

    echo -e """\n# rust\n\
export CARGO_HOME=$CARGO_HOME\n\
export PATH=\$PATH:\$CARGO_HOME/bin\n\
""" >> /etc/profile && \

## install toolchain
source /etc/profile && rustup default stable