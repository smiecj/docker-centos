ARG IMAGE_PYTHON
FROM ${IMAGE_PYTHON}

ENV PORT=27071

COPY ./scripts/mongo-start.sh /usr/local/bin/mongostart
COPY ./scripts/mongo-stop.sh /usr/local/bin/mongostop
COPY ./scripts/mongo-restart.sh /usr/local/bin/mongorestart
COPY ./scripts/init-mongo.sh /tmp

ARG mongo_version
ARG module_home

ENV mongo_data_home=/opt/data/mongodb
ENV mongo_log_home=/var/log/mongodb
ENV mongo_log=mongo.log

# install mongo
ARG TARGETARCH
RUN mongo_module_home=${module_home}/mongo && \
    mongo_scripts_home=${mongo_module_home}/scripts && \
    mkdir -p ${mongo_module_home} && mkdir -p ${mongo_scripts_home} && \
    cd ${mongo_module_home} && if [ "arm64" == "$TARGETARCH" ]; \
then\
    arch="aarch64" && system_version="rhel82";\
else\
    arch="x86_64" && system_version="rhel80";\
fi && \
mongo_pkg=mongodb-linux-${arch}-${system_version}-${version}.tgz && \
mongo_pkg_url=https://fastdl.mongodb.org/linux/${mongo_pkg} && \
curl -LO ${mongo_pkg_url} && tar -xzvf ${mongo_pkg} && rm ${mongo_pkg} && \
mongo_pkg_folder=`ls -l | grep "mongodb-linux-${arch}-${system_version}-${version}" | sed 's#.* ##g'` && \
mv ${mongo_pkg_folder}/* ./ && rm -rf ${mongo_pkg_folder} && \

# bin path
echo -e """\n# mongo\n\
export MONGO_HOME=${mongo_module_home}/bin\n\
export PATH=\$PATH:\$MONGO_HOME/bin\n\
""" >> /etc/profile && \

# script
    mv /tmp/init-mongo.sh ${mongo_scripts_home}/ && \
    chmod +x /usr/local/bin/mongostart && chmod +x /usr/local/bin/mongostop && chmod +x /usr/local/bin/mongorestart && \

## init script
    echo "sh ${mongo_scripts_home}/init-mongo.sh && mongostart" >> /init_service