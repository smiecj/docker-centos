ARG IMAGE_PYTHON
FROM ${IMAGE_PYTHON}

ENV PORT=27017

ARG github_url
ARG module_home
ARG mongo_version

ENV mongo_data_home=/opt/data/mongodb
ENV mongo_log_home=/var/log/mongodb
ENV mongo_log=mongo.log

# copy script
COPY ./scripts/mongo-start.sh /usr/local/bin/mongostart
COPY ./scripts/mongo-stop.sh /usr/local/bin/mongostop
COPY ./scripts/mongo-restart.sh /usr/local/bin/mongorestart
COPY ./scripts/init-mongo.sh /tmp

# install mongo
RUN mongo_release_version=r${mongo_version} && \
    mongo_module_home=${module_home}/mongo && \
    mongo_scripts_home=${mongo_moduley_home}/scripts && \
    mongo_source_pkg=${mongo_release_version}.tar.gz && \
    mongo_source_pkg_url=${github_url}/mongodb/mongo/archive/refs/tags/${mongo_source_pkg} && \
    mongo_source_folder=mongo-${mongo_release_version} && \
    mkdir -p ${mongo_module_home} && \
    cd /tmp && curl -LO ${mongo_source_pkg_url} && tar -xzvf ${mongo_source_pkg} && rm ${mongo_source_pkg} && \
    cd ${mongo_source_folder} && source /etc/profile && \
    yum -y install libcurl-devel && \
    python3 -m pip install requirements_parser && \
    python3 -m pip install -r etc/pip/compile-requirements.txt && \
    python3 buildscripts/scons.py MONGO_VERSION=${mongo_version} DESTDIR=${mongo_module_home} install-mongod && \
    cd .. && rm -rf ${mongo_source_folder} && \

# bin path
echo -e """\n# mongo\n\
export MONGO_HOME=${mongo_module_home}/bin\n\
export PATH=\$PATH:\$MONGO_HOME/bin\n\
""" >> /etc/profile && \

    mv /tmp/init-mongo.sh ${mongo_scripts_home}/ && \
    chmod +x /usr/local/bin/mongostart && chmod +x /usr/local/bin/mongostop && chmod +x /usr/local/bin/mongorestart && \
## init script
    mkdir -p ${mongo_scripts_home} && \
    echo "sh ${mongo_scripts_home}/init-mongo.sh && mongostart" >> /init_service
