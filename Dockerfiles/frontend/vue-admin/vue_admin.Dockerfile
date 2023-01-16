ARG IMAGE_NODEJS
FROM ${IMAGE_NODEJS}

ARG github_url
ARG vue_admin_version
ARG code_home

ENV PORT=9527

# scripts
COPY ./scripts/vue-start.sh /usr/local/bin/vuestart
COPY ./scripts/vue-restart.sh /usr/local/bin/vuerestart
COPY ./scripts/vue-stop.sh /usr/local/bin/vuestop

# download code
RUN yum -y install python3 && \
    vue_admin_code_pkg=${vue_admin_version}.tar.gz && \
    vue_admin_code_url=${github_url}/PanJiaChen/vue-element-admin/archive/refs/tags/${vue_admin_code_pkg} && \
    vue_admin_folder=vue-element-admin-${vue_admin_version} && \
    mkdir -p ${code_home} && cd ${code_home} && curl -LO ${vue_admin_code_url} && \
    tar -xzvf ${vue_admin_code_pkg} && rm ${vue_admin_code_pkg} && \

# npm install
    cd ${code_home}/${vue_admin_folder} && source /etc/profile && npm install && \
    vue_admin_log=${code_home}/${vue_admin_folder}/admin.log && \

# config
## Invalid Host header: https://www.jianshu.com/p/219d8f83803b
## skip hostname check
    sed -i 's/devServer: {/devServer: {\n    disableHostCheck: true,/g' ${code_home}/${vue_admin_folder}/vue.config.js && \

    sed -i "s#{vue_admin_home}#${code_home}/${vue_admin_folder}#g" /usr/local/bin/vuestart && \
    sed -i "s#{vue_admin_log}#${vue_admin_log}#g" /usr/local/bin/vuestart && \
    chmod +x /usr/local/bin/vuestart && \
    chmod +x /usr/local/bin/vuerestart && \
    chmod +x /usr/local/bin/vuestop && \

# init service
    echo "vuestart" >> /init_service && \

# log
    addlogrotate ${vue_admin_log} vue_admin