ARG IMAGE_MINIMAL
FROM ${IMAGE_MINIMAL}

# install redis
ARG github_repo
ARG redis_version
ARG module_home

ENV PORT=6379

# scripts
COPY scripts/init-redis.sh /tmp

## download source code
RUN yum -y install gcc && \
    redis_module_path=${module_home}/redis && \
    redis_bin_path=${redis_module_path}/bin && \
    redis_scripts_path=${redis_module_path}/scripts && \
    redis_log_path=${redis_module_path}/redis_server.log && \
    mkdir -p ${redis_scripts_path} && \
    redis_download_url=${github_repo}/redis/redis/archive/${redis_version}.tar.gz && \
    redis_pkg=redis_code.tar.gz && \
    redis_code_folder=redis-${redis_version} && \
    mkdir -p ${redis_module_path} && mkdir -p ${redis_bin_path} && mkdir -p ${redis_scripts_path} && \
    cd ${redis_module_path} && curl -L ${redis_download_url} -o ${redis_pkg} && \
    tar -xzvf ${redis_pkg} && rm -f ${redis_pkg} && \
    cd ${redis_module_path}/${redis_code_folder} && make && \
    cp src/redis-cli $redis_bin_path && \
    cp src/redis-server $redis_bin_path && \
    cp src/redis-sentinel $redis_bin_path && \
    cp src/redis-benchmark $redis_bin_path && \
    cp redis.conf ${redis_module_path} && \
    rm -rf ${redis_module_path}/${redis_code_folder} && \

## init config
    cd ${redis_module_path} && sed -i "s#logfile \"\"#logfile $redis_log_path#g" redis.conf && \

### set default bind (allow all host) and protected mode (no)
    cd ${redis_module_path} && sed -i "s/^protected-mode .*/protected-mode no/g" redis.conf && \
    cd ${redis_module_path} && sed -i "s/^bind .*/bind * -::*/g" redis.conf  && \

### init config script
    mv /tmp/init-redis.sh ${redis_scripts_path}/ && \
    sed -i "s#{redis_module_path}#${redis_module_path}#g" ${redis_scripts_path}/init-redis.sh && \
    echo "sh ${redis_scripts_path}/init-redis.sh" >> /init_service && \
    echo "redisrestart" >> /init_service && \

### profile
    echo -e '\n# redis' >> /etc/profile && \
    echo "export PATH=\$PATH:${redis_bin_path}" >> /etc/profile && \

### start and stop command
    echo -e """#!/bin/bash\n\
redisstop\n\
sleep 3\n\
\n\
nohup ${redis_bin_path}/redis-server ${redis_module_path}/redis.conf > ${redis_log_path} 2>&1 &\n\
""" >> /usr/local/bin/redisrestart && chmod +x /usr/local/bin/redisrestart && \

    echo -e """#!/bin/bash\n\
\n\
ps -ef | grep \"${redis_module_path}\" | grep -v grep | awk '{print \$2}' | xargs --no-run-if-empty kill -9\n\
sleep 3\n\
""" >> /usr/local/bin/redisstop && chmod +x /usr/local/bin/redisstop && \

### add redis log rotate
    addlogrotate ${redis_log_path} redis-server