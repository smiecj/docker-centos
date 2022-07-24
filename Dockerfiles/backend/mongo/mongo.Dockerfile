FROM centos_python

ENV PORT=27071

ARG version=6.0.0
ARG mongo_module_home=/opt/modules/mongo
ARG mongo_scripts_home=${mongo_module_home}/scripts

ENV mongo_data_home=/opt/data/mongodb
ENV mongo_log_home=/var/log/mongodb
ENV mongo_log=mongo.log

# install mongo
ARG TARGETARCH
RUN mkdir -p ${mongo_module_home}
RUN cd ${mongo_module_home} && if [ "arm64" == "$TARGETARCH" ]; \
then\
    arch="aarch64" && system_version="rhel82";\
else\
    arch="x86_64" && system_version="rhel80";\
fi && \
mongo_pkg_folder=mongodb-linux-${arch}-${system_version}-${version} && \
mongo_pkg=mongodb-linux-${arch}-${system_version}-${version}.tgz && \
mongo_pkg_url=https://fastdl.mongodb.org/linux/${mongo_pkg} && \
curl -LO ${mongo_pkg_url} && tar -xzvf ${mongo_pkg} && \
mv ${mongo_pkg_folder}/* ./ && rm -rf ${mongo_pkg_folder} && rm -f ${mongo_pkg}

# bin path
RUN echo -e """\n# mongo\n\
export MONGO_HOME=${mongo_module_home}/bin\n\
export PATH=\$PATH:\$MONGO_HOME/bin\n\
""" >> /etc/profile

# copy script
COPY ./scripts/mongo-start.sh /usr/local/bin/mongostart
COPY ./scripts/mongo-stop.sh /usr/local/bin/mongostop
COPY ./scripts/mongo-restart.sh /usr/local/bin/mongorestart
RUN chmod +x /usr/local/bin/mongostart && chmod +x /usr/local/bin/mongostop && chmod +x /usr/local/bin/mongorestart

## init script
RUN mkdir -p ${mongo_scripts_home}
COPY ./scripts/init-mongo.sh ${mongo_scripts_home}/
RUN echo "sh ${mongo_scripts_home}/init-mongo.sh && mongostart" >> /init_service
