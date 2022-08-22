ARG PYTHON_IMAGE
FROM ${PYTHON_IMAGE} as base_python

# install superset
ARG superset_version=1.4.2
ENV PORT=8088

ARG superset_module_home=/home/modules/superset
ARG superset_scripts_home=${superset_module_home}/scripts
ARG superset_log=${superset_module_home}/server.log

ARG superset_username=admin
ARG superset_first_name=admin
ARG superset_last_name=admin
ARG superset_email=admin@123.com
ARG superset_password=admin123

## pip install superset
RUN source /etc/profile && \
    pip3 install apache-superset==$superset_version && \
    pip3 install markupsafe==2.0.1 && \
    pip3 install Pillow==9.1.0

## superset config
RUN source /etc/profile && superset db upgrade

## Create an admin user in your metadata database (use `admin` as username to be able to load the examples)
RUN echo -e """\n\
# superset\n\
export FLASK_APP=supersets""" >> /etc/profile

RUN source /etc/profile && \
    superset fab create-admin --username ${superset_username} --firstname ${superset_first_name} --lastname ${superset_last_name} --email ${superset_email} --password ${superset_password} && \
    superset load_examples && \
    superset init

### add and enable superset service
RUN mkdir -p ${superset_scripts_home}

COPY ./scripts/superset-restart.sh /usr/local/bin/supersetrestart
COPY ./scripts/superset-start.sh /usr/local/bin/supersetstart
COPY ./scripts/superset-stop.sh /usr/local/bin/supersetstop
RUN chmod +x /usr/local/bin/supersetrestart && chmod +x /usr/local/bin/supersetstart && chmod +x /usr/local/bin/supersetstop
RUN sed -i "s#{superset_log}#$superset_log#g" /usr/local/bin/supersetstart
RUN echo "supersetstart" >> /init_service
RUN addlogrotate ${superset_log} superset