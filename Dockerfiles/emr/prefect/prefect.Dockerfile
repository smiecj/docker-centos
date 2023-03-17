ARG IMAGE_PYTHON
FROM ${IMAGE_PYTHON}

# install prefect
ENV PORT=3000
ENV API_URL=http://localhost:3000/api

ARG prefect_version
ARG module_home

## scripts
COPY ./scripts/prefect-restart.sh /usr/local/bin/prefectrestart
COPY ./scripts/prefect-start.sh /usr/local/bin/prefectstart
COPY ./scripts/prefect-stop.sh /usr/local/bin/prefectstop

RUN prefect_module_home=${module_home}/prefect && \
    prefect_orion_log=${prefect_module_home}/orion.log && \
    prefect_test_queue_log=${prefect_module_home}/test_queue.log && \
    mkdir -p ${prefect_module_home} && \

    source /etc/profile && \
    pip3 install "prefect==${prefect_version}" && \

## copy start and stop script
    sed -i "s#{prefect_orion_log}#${prefect_orion_log}#g" /usr/local/bin/prefectstart && \
    sed -i "s#{prefect_test_queue_log}#${prefect_test_queue_log}#g" /usr/local/bin/prefectstart && \
    chmod +x /usr/local/bin/prefectstop && chmod +x /usr/local/bin/prefectstart && chmod +x /usr/local/bin/prefectrestart && \

## auto start at reboot
    echo "prefectstart" >> /init_service && \

## log rotate
    addlogrotate ${prefect_orion_log} prefect_orion && \
    addlogrotate ${prefect_test_queue_log} prefect_test_queue