ARG IMAGE_MINIMAL
FROM ${IMAGE_MINIMAL}

ARG module_home
ARG nginx_version

## env
ENV PORT 80

# copy scripts & config
COPY ./conf/nginx.conf_template /tmp/
COPY ./scripts/init-nginx.sh /tmp/
COPY ./scripts/nginx-start.sh /usr/local/bin/nginxstart
COPY ./scripts/nginx-stop.sh /usr/local/bin/nginxstop
COPY ./scripts/nginx-restart.sh /usr/local/bin/nginxrestart
COPY ./scripts/nginx-log.sh /usr/local/bin/nginxlog
COPY ./scripts/nginx-reload.sh /usr/local/bin/nginxreload

## download package
RUN nginx_repo=http://nginx.org && \
    nginx_module_home=${module_home}/nginx && \
    yum -y install gcc pcre-devel openssl-devel && \
    mkdir -p ${nginx_module_home} && cd ${nginx_module_home} && \
    nginx_code_folder=nginx-${nginx_version} && \
    nginx_code_pkg=${nginx_code_folder}.tar.gz && \
    curl -LO ${nginx_repo}/download/${nginx_code_pkg} && \
    tar -xzvf ${nginx_code_pkg} && \
    rm ${nginx_code_pkg} && \
    cd ${nginx_code_folder} && \
    ./configure \
    --sbin-path=${nginx_module_home}/nginx \
    --conf-path=${nginx_module_home}/nginx.conf \
    --pid-path=${nginx_module_home}/nginx.pid \
    --with-http_ssl_module && \
    make && make install && \
    cd .. && rm -r ${nginx_code_folder} && mkdir -p logs && \

    mv /tmp/nginx.conf_template ${nginx_module_home}/ && \
    mv /tmp/init-nginx.sh ${nginx_module_home}/ && \
    sed -i "s#{nginx_module_home}#${nginx_module_home}#g" ${nginx_module_home}/init-nginx.sh && \
    sed -i "s#{nginx_module_home}#${nginx_module_home}#g" /usr/local/bin/nginxstart && \
    sed -i "s#{nginx_module_home}#${nginx_module_home}#g" /usr/local/bin/nginxlog && \
    sed -i "s#{nginx_module_home}#${nginx_module_home}#g" /usr/local/bin/nginxreload && \
    chmod +x /usr/local/bin/nginxstart && chmod +x /usr/local/bin/nginxstop && chmod +x /usr/local/bin/nginxrestart && \
    chmod +x /usr/local/bin/nginxlog && chmod +x /usr/local/bin/nginxreload && \

# init
    echo "sh ${nginx_module_home}/init-nginx.sh && nginxstart" >> /init_service