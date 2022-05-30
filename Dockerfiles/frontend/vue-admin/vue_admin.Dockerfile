FROM centos_nodejs

ARG admin_version=4.4.0
ARG admin_code_url=https://github.com/PanJiaChen/vue-element-admin/archive/refs/tags/${admin_version}.tar.gz
ARG admin_code_pkg=${admin_version}.tar.gz
ARG admin_folder=vue-element-admin-${admin_version}
ARG admin_code_home=/home/coding
ARG admin_log=${admin_code_home}/${admin_folder}/admin.log

ENV PORT=9527

# download code
RUN mkdir -p ${admin_code_home} && cd ${admin_code_home} && curl -LO ${admin_code_url} && \
    tar -xzvf ${admin_code_pkg} && rm -f ${admin_code_pkg}

# npm install
RUN cd ${admin_code_home}/${admin_folder} && source /etc/profile && npm install

# config
## Invalid Host header: https://www.jianshu.com/p/219d8f83803b
## skip hostname check
RUN sed -i 's/devServer: {/devServer: {\n    disableHostCheck: true,/g' ${admin_code_home}/${admin_folder}/vue.config.js

# scripts
COPY ./scripts/vue-start.sh /usr/local/bin/vuestart
RUN sed -i "s#{vue_admin_home}#${admin_code_home}/${admin_folder}#g" /usr/local/bin/vuestart
RUN sed -i "s#{vue_admin_log}#${admin_log}#g" /usr/local/bin/vuestart
RUN chmod +x /usr/local/bin/vuestart

COPY ./scripts/vue-restart.sh /usr/local/bin/vuerestart
RUN chmod +x /usr/local/bin/vuerestart

COPY ./scripts/vue-stop.sh /usr/local/bin/vuestop
RUN chmod +x /usr/local/bin/vuestop

# init service
RUN echo "vuestart" >> /init_service

# log
RUN addlogrotate ${admin_log} vue_admin