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
ENV AIRFLOW_DB_INIT=true

ENV MYSQL_HOST=
ENV MYSQL_PORT=
ENV MYSQL_DB=
ENV MYSQL_USER=
ENV MYSQL_PASSWORD=

ENV FLASK_SECRET_KEY=temp_secret_key

ENV EXECUTOR=SequentialExecutor
ENV CELERY_BROKER_TYPE=

ENV AIRFLOW_START=airflowstartsingleton

## scripts
COPY ./scripts/ /tmp
COPY constraints_airflow_*.txt /tmp

RUN yum -y install mysql && \

    airflow_log_home=/var/log/airflow && \
    airflow_log_webserver=${airflow_log_home}/webserver.log && \
    airflow_log_scheduler=${airflow_log_home}/scheduler.log && \
    airflow_log_worker=${airflow_log_home}/worker.log && \
    mkdir -p ${airflow_log_home} && \
    airflow_module_home=${module_home}/airflow && \

## install
    source /etc/profile && \
    constraint_file=constraints_airflow_${airflow_version}.txt && \
    # pip3 install "apache-airflow==${airflow_version}" --constraint /tmp/${constraint_file} && \
    pip3 install -r /tmp/${constraint_file} && \
    rm /tmp/constraints_airflow_*.txt && \

## initialize the database
    mkdir -p ${airflow_module_home} && \
    mv /tmp/init-airflow.sh ${airflow_module_home}/ && \

    mv /tmp/airflow-webserver-start.sh /usr/local/bin/airflowwebserverstart && \
    mv /tmp/airflow-webserver-stop.sh /usr/local/bin/airflowwebserverstop && \
    mv /tmp/airflow-webserver-restart.sh /usr/local/bin/airflowwebserverrestart && \

    mv /tmp/airflow-scheduler-start.sh /usr/local/bin/airflowschedulerstart && \
    mv /tmp/airflow-scheduler-stop.sh /usr/local/bin/airflowschedulerstop && \
    mv /tmp/airflow-scheduler-restart.sh /usr/local/bin/airflowschedulerrestart && \

    mv /tmp/airflow-worker-start.sh /usr/local/bin/airflowworkerstart && \
    mv /tmp/airflow-worker-stop.sh /usr/local/bin/airflowworkerstop && \
    mv /tmp/airflow-worker-restart.sh /usr/local/bin/airflowworkerrestart && \

    mv /tmp/airflow-start-singleton.sh /usr/local/bin/airflowstartsingleton && \
    
    mv /tmp/airflow-webserver-log.sh /usr/local/bin/airflowwebserverlog && \
    mv /tmp/airflow-scheduler-log.sh /usr/local/bin/airflowschedulerlog && \
    mv /tmp/airflow-worker-log.sh /usr/local/bin/airflowworkerlog && \

## copy start and stop script
    sed -i "s#{airflow_module_home}#${airflow_module_home}#g" ${airflow_module_home}/init-airflow.sh && \
    sed -i "s#{airflow_module_home}#${airflow_module_home}#g" /usr/local/bin/airflow* && \
    sed -i "s#{airflow_log_webserver}#${airflow_log_webserver}#g" /usr/local/bin/airflow* && \
    sed -i "s#{airflow_log_scheduler}#${airflow_log_scheduler}#g" /usr/local/bin/airflow* && \
    sed -i "s#{airflow_log_worker}#${airflow_log_worker}#g" /usr/local/bin/airflow* && \
    chmod +x /usr/local/bin/airflow* && \
## auto start at reboot
    echo "sh ${airflow_module_home}/init-airflow.sh && \${AIRFLOW_START}" >> /init_service && \

## log rotate
    addlogrotate ${airflow_log_webserver} webserver && \
    addlogrotate ${airflow_log_scheduler} scheduler && \
    addlogrotate ${airflow_log_worker} worker
