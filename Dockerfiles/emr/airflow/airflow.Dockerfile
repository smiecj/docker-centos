ARG IMAGE_PYTHON
FROM ${IMAGE_PYTHON}

# install airflow
ENV AIRFLOW_HOME=$HOME/.airflow
ENV AIRFLOW_PORT=8072

ARG airflow_version
ARG module_home

ARG airflow_default_user_name=airflow
ARG airflow_default_user_password=airflow123
ARG airflow_default_user_firstname=Peter
ARG airflow_default_user_lastname=Parker
ARG airflow_default_user_email=spiderman@superhero.org

ARG airflow_admin_role=Admin
ARG airflow_admin_username=admin
ARG airflow_admin_password=admin123

## scripts
COPY ./scripts/airflow-restart.sh /usr/local/bin/airflowrestart
COPY ./scripts/airflow-start.sh /usr/local/bin/airflowstart
COPY ./scripts/airflow-stop.sh /usr/local/bin/airflowstop
COPY constraints_airflow_*.txt /tmp

RUN airflow_log_home=/var/log/airflow && \
    airflow_log_webserver=${airflow_log_home}/webserver.log && \
    airflow_log_scheduler=${airflow_log_home}/scheduler.log && \
    mkdir -p ${airflow_log_home} && \
    airflow_module_home=${module_home}/airflow && \

## install
    source /etc/profile && \
    constraint_file=constraints_airflow_${airflow_version}.txt && \
    pip3 install "apache-airflow==${airflow_version}" --constraint /tmp/${constraint_file} && \
    rm /tmp/constraints_airflow_*.txt && \

## initialize the database
    airflow db init && \
    airflow users create \
    --username ${airflow_admin_username} \
    --password ${airflow_admin_password} \
    --firstname ${airflow_default_user_firstname} \
    --lastname ${airflow_default_user_lastname} \
    --role ${airflow_admin_role} \
    --email ${airflow_default_user_email} && \

## copy start and stop script
    sed -i "s#{airflow_log_webserver}#$airflow_log_webserver#g" /usr/local/bin/airflowstart && \
    sed -i "s#{airflow_log_scheduler}#$airflow_log_scheduler#g" /usr/local/bin/airflowstart && \
    chmod +x /usr/local/bin/airflowrestart && chmod +x /usr/local/bin/airflowstart && chmod +x /usr/local/bin/airflowstop && \
## auto start at reboot
    echo "airflowstart" >> /init_service && \

## log rotate
    addlogrotate $airflow_log_webserver webserver && \
    addlogrotate $airflow_log_scheduler scheduler
