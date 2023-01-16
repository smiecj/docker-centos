ARG IMAGE_PYTHON
FROM ${IMAGE_PYTHON} as base_python

# install superset
ENV PORT=8088

ARG module_home
ARG superset_version
ARG github_url
ARG github_raw

ARG superset_username=admin
ARG superset_first_name=admin
ARG superset_last_name=admin
ARG superset_email=admin@123.com
ARG superset_password=admin123

COPY ./scripts/superset-restart.sh /usr/local/bin/supersetrestart
COPY ./scripts/superset-start.sh /usr/local/bin/supersetstart
COPY ./scripts/superset-stop.sh /usr/local/bin/supersetstop

## pip install superset
COPY ./requirements_superset*.txt /tmp/
RUN superset_module_home=${module_home}/superset && \
    superset_scripts_home=${superset_module_home}/scripts && \
    superset_log=${superset_module_home}/server.log && \

    pip3 install -r /tmp/requirements_superset_${superset_version}.txt --quiet --no-cache-dir -vvv && \
    rm /tmp/requirements_superset*.txt && \

## Create an admin user in your metadata database (use `admin` as username to be able to load the examples)
    echo -e """\n\
# superset\n\
export FLASK_APP=superset""" >> /etc/profile && \

## superset config
    source /etc/profile && \
    sed -i "s#https://github.com#${github_url}#g" ${PYTHON3_LIB_HOME}/superset/examples/helpers.py && \
    sed -i "s#https://raw.githubusercontent.com#${github_raw}#g" ${PYTHON3_LIB_HOME}/superset/examples/configs/datasets/examples/* && \
    sed -i "s#https://github.com#${github_url}#g" ${PYTHON3_LIB_HOME}/superset/examples/configs/datasets/examples/* && \
    superset db upgrade && \
    superset fab create-admin --username ${superset_username} --firstname ${superset_first_name} --lastname ${superset_last_name} --email ${superset_email} --password ${superset_password} && \
    superset load_examples && \
    superset init && \

    chmod +x /usr/local/bin/supersetrestart && chmod +x /usr/local/bin/supersetstart && chmod +x /usr/local/bin/supersetstop && \
    sed -i "s#{superset_log}#$superset_log#g" /usr/local/bin/supersetstart && \
    echo "supersetstart" >> /init_service && \
    addlogrotate ${superset_log} superset