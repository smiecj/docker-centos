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
ARG superset_secret_key=superset

COPY ./scripts/superset-restart.sh /usr/local/bin/supersetrestart
COPY ./scripts/superset-start.sh /usr/local/bin/supersetstart
COPY ./scripts/superset-stop.sh /usr/local/bin/supersetstop
COPY ./scripts/superset-log.sh /usr/local/bin/supersetlog

## pip install superset
RUN superset_module_home=${module_home}/superset && \
    superset_scripts_home=${superset_module_home}/scripts && \
    superset_log=${superset_module_home}/server.log && \
    mkdir -p ${superset_module_home} && \

    pip3 install apache-superset==${superset_version} && \
    # https://github.com/apache/superset/issues/23742#issuecomment-1517789743
    echo "[test] syoerset version: ${superset_version}" && \
    if [[ "${superset_version}" =~ ^2.*.* ]]; then \
        pip3 install sqlparse==0.4.3 && pip3 install marshmallow_enum;\
    fi && \

## Create an admin user in your metadata database (use `admin` as username to be able to load the examples)
    echo -e """\n\
# superset\n\
export FLASK_APP=superset""" >> /etc/profile && \

## superset config
    source /etc/profile && \
    sed -i "s#https://github.com#${github_url}#g" ${PYTHON3_LIB_HOME}/superset/examples/helpers.py && \
    sed -i "s#https://raw.githubusercontent.com#${github_raw}#g" ${PYTHON3_LIB_HOME}/superset/examples/configs/datasets/examples/* && \
    sed -i "s#https://github.com#${github_url}#g" ${PYTHON3_LIB_HOME}/superset/examples/configs/datasets/examples/* && \
    
    ## https://github.com/apache/superset/issues/24201#issuecomment-1626864509
    export SUPERSET_SECRET_KEY=`echo "${superset_secret_key}" | base64` && \
    superset db upgrade && \
    superset fab create-admin --username ${superset_username} --firstname ${superset_first_name} --lastname ${superset_last_name} --email ${superset_email} --password ${superset_password} && \
    superset load_examples && \
    superset init && \

    chmod +x /usr/local/bin/supersetrestart && chmod +x /usr/local/bin/supersetstart && chmod +x /usr/local/bin/supersetstop && \
    chmod +x /usr/local/bin/supersetlog && \
    sed -i "s#{superset_log}#${superset_log}#g" /usr/local/bin/supersetstart && \
    sed -i "s#{superset_secret_key}#${superset_secret_key}#g" /usr/local/bin/supersetstart && \
    sed -i "s#{superset_log}#${superset_log}#g" /usr/local/bin/supersetlog && \
    echo "supersetstart" >> /init_service && \
    addlogrotate ${superset_log} superset