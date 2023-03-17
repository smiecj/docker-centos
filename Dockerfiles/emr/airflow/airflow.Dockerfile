ARG IMAGE_PYTHON
FROM ${IMAGE_PYTHON}

ARG airflow_version
ARG module_home
ARG data_home

ENV ADMIN_USER_NAME=admin
ENV ADMIN_USER_PASSWORD=admin
ENV ADMIN_USER_FIRSTNAME=Peter
ENV ADMIN_USER_LASTNAME=Parker
ENV ADMIN_USER_MAIL=spiderman@superhero.org
ENV AIRFLOW_PORT=8072

## scripts
COPY ./scripts/airflow-restart.sh /usr/local/bin/airflowrestart
COPY ./scripts/airflow-start.sh /usr/local/bin/airflowstart
COPY ./scripts/airflow-stop.sh /usr/local/bin/airflowstop
COPY ./scripts/init-airflow.sh /tmp
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
    mkdir -p ${airflow_module_home} && \
    mv /tmp/init-airflow.sh ${airflow_module_home}/ && \

## copy start and stop script
    sed -i "s#{airflow_module_home}#$airflow_module_home#g" ${airflow_module_home}/init-airflow.sh && \
    sed -i "s#{airflow_module_home}#$airflow_module_home#g" /usr/local/bin/airflowstart && \
    sed -i "s#{airflow_log_webserver}#$airflow_log_webserver#g" /usr/local/bin/airflowstart && \
    sed -i "s#{airflow_log_scheduler}#$airflow_log_scheduler#g" /usr/local/bin/airflowstart && \
    chmod +x /usr/local/bin/airflowrestart && chmod +x /usr/local/bin/airflowstart && chmod +x /usr/local/bin/airflowstop && \
## auto start at reboot
    echo "sh ${airflow_module_home}/init-airflow.sh && airflowstart" >> /init_service && \

## log rotate
    addlogrotate $airflow_log_webserver webserver && \
    addlogrotate $airflow_log_scheduler scheduler
