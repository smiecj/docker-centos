FROM ${PYTHON_IMAGE}

ENV PORT=27071

ARG short_version=6.0.0
ARG version=r${short_version}
ARG mongo_source_pkg_url=https://github.com/mongodb/mongo/archive/refs/tags/${version}.tar.gz
ARG mongo_source_pkg=${version}.tar.gz
ARG mongo_source_folder=mongo-${version}
ARG mongo_module_home=/opt/modules/mongo
ARG mongo_scripts_home=${mongo_moduley_home}/scripts

ENV mongo_data_home=/opt/data/mongodb
ENV mongo_log_home=/var/log/mongodb
ENV mongo_log=mongo.log

# install mongo
RUN mkdir -p ${mongo_module_home}
RUN cd /tmp && curl -LO ${mongo_source_pkg_url} && tar -xzvf ${mongo_source_pkg} && rm ${mongo_source_pkg} && \
    cd ${mongo_source_folder} && source /etc/profile && \
    yum -y install libcurl-devel && \
    python3 -m pip install requirements_parser && \
    python3 -m pip install -r etc/pip/compile-requirements.txt && \
    python3 buildscripts/scons.py MONGO_VERSION=${short_version} DESTDIR=${mongo_module_home} install-mongod && \
    cd .. && rm -rf ${mongo_source_folder}

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
