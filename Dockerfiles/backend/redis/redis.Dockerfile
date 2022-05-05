FROM centos_base

# install redis

ARG redis_version=7.0-rc2
ARG redis_download_url=https://github.com/redis/redis/archive/$redis_version.tar.gz
ARG redis_pkg=redis_code.tar.gz
ARG redis_code_folder=redis-$redis_version

ENV redis_module_path=/home/modules/redis
ARG redis_bin_path=${redis_module_path}/bin
ARG redis_scripts_path=${redis_module_path}/scripts
ARG redis_log_path=${redis_module_path}/redis_server.log

ENV PORT=6379

## download source code
RUN mkdir -p ${redis_module_path} && mkdir -p ${redis_bin_path} && mkdir -p ${redis_scripts_path}
RUN cd ${redis_module_path} && curl -L ${redis_download_url} -o ${redis_pkg} && \
    tar -xzvf ${redis_pkg} && rm -f ${redis_pkg}
RUN cd ${redis_module_path}/${redis_code_folder} && make && \
    cp src/redis-cli $redis_bin_path && \
    cp src/redis-server $redis_bin_path && \
    cp src/redis-sentinel $redis_bin_path && \
    cp src/redis-benchmark $redis_bin_path && \
    cp redis.conf ${redis_module_path}
RUN rm -rf ${redis_module_path}/${redis_code_folder}

## init config
RUN cd ${redis_module_path} && sed -i "s#logfile \"\"#logfile $redis_log_path#g" redis.conf

### set default bind (allow all host) and protected mode (no)
RUN cd ${redis_module_path} && sed -i "s/^protected-mode .*/protected-mode no/g" redis.conf
RUN cd ${redis_module_path} && sed -i "s/^bind .*/bind * -::*/g" redis.conf

### init config script
COPY scripts/init-redis.sh ${redis_scripts_path}/
RUN echo "sh ${redis_scripts_path}/init-redis.sh" >> /init_service
RUN echo "redisrestart" >> /init_service

### profile
RUN echo -e '\n# redis' >> /etc/profile
RUN echo "export PATH=\$PATH:${redis_bin_path}" >> /etc/profile

### start and stop command
RUN echo -e """#!/bin/bash\n\
redisstop\n\
sleep 3\n\
\n\
nohup ${redis_bin_path}/redis-server ${redis_module_path}/redis.conf > ${redis_log_path} 2>&1 &\n\
""" >> /usr/local/bin/redisrestart && chmod +x /usr/local/bin/redisrestart

RUN echo -e """#!/bin/bash\n\
\n\
ps -ef | grep \"${redis_module_path}\" | grep -v grep | awk '{print \$2}' | xargs --no-run-if-empty kill -9\n\
sleep 3\n\
""" >> /usr/local/bin/redisstop && chmod +x /usr/local/bin/redisstop

### add redis log rotate
RUN addlogrotate ${redis_log_path} redis-server