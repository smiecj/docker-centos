ARG IMAGE_GO
FROM ${IMAGE_GO}

ARG module_home
ARG minio_branch
ARG github_url
ARG repo_home

## env
ENV PORT=9000
ENV WEB_PORT=9001
ENV DATA_HOME=/opt/data

ENV ROOT_USER=minioadmin
ENV ROOT_PASSWORD=minioadmin
ENV ACCESS_KEY=minioadmin
ENV SECRET_KEY=minioadmin123

# scripts
COPY ./scripts/minio-start.sh /usr/local/bin/miniostart
COPY ./scripts/minio-stop.sh /usr/local/bin/miniostop
COPY ./scripts/minio-restart.sh /usr/local/bin/miniorestart

RUN minio_module_home=${module_home}/minio && \
    go_repo_home=${repo_home}/go && \
    minio_log=${minio_module_home}/minio.log && \

## compile minio
    cd /tmp && git clone ${github_url}/minio/minio -b ${minio_branch} && \
    cd minio && source /etc/profile && make build && \
    mkdir -p ${minio_module_home} && mv minio ${minio_module_home}/ && \
    cd ${minio_module_home} && rm -r /tmp/minio && rm -r ${go_repo_home}/* && \

    sed -i "s#{minio_module_home}#${minio_module_home}#g" /usr/local/bin/miniostart && \
    sed -i "s#{minio_log}#${minio_log}#g" /usr/local/bin/miniostart && \
    chmod +x /usr/local/bin/miniostart && chmod +x /usr/local/bin/miniostop && chmod +x /usr/local/bin/miniorestart && \
# init
    echo "miniostart" >> /init_service && \
    addlogrotate ${minio_log} minio