FROM centos_python

# install airflow
USER root
ENV HOME /root
ENV AIRFLOW_HOME=$HOME/.airflow
ENV airflow_webserver_port=8072

ARG airflow_version=2.1.2

ARG airflow_default_user_name=airflow
ARG airflow_default_user_password=airflow123
ARG airflow_default_user_firstname=Peter
ARG airflow_default_user_lastname=Parker
ARG airflow_default_user_email=spiderman@superhero.org

ARG airflow_admin_role=Admin
ARG airflow_admin_username=admin
ARG airflow_admin_password=admin123

ARG airflow_log_home=/var/log/airflow
ARG airflow_log_webserver=${airflow_log_home}/webserver.log
ARG airflow_log_scheduler=${airflow_log_home}/scheduler.log

ARG airflow_module_home=/home/modules/airflow

## prepare env
RUN yum -y install python3-devel && python3 -m pip install --upgrade pip && \
    pip3 install setuptools_rust && \
    pip3 install wheel && \
    pip3 install cpython && \
    pip3 install cython && \
    pip3 install numpy

## install
RUN python3_short_version="$(python3 --version | cut -d " " -f 2 | cut -d "." -f 1-2)" && \
    requirement_url="https://raw.githubusercontent.com/apache/airflow/constraints-${airflow_version}/constraints-$python3_short_version.txt" && \
    pip3 install "apache-airflow==${airflow_version}" --constraint "${requirement_url}" -i https://pypi.tuna.tsinghua.edu.cn/simple

## initialize the database
RUN source /etc/profile && airflow db init && \
    airflow users create \
    --username ${airflow_admin_username} \
    --password ${airflow_admin_password} \
    --firstname ${airflow_default_user_firstname} \
    --lastname ${airflow_default_user_lastname} \
    --role ${airflow_admin_role} \
    --email ${airflow_default_user_email}

## copy start and stop script
COPY ./scripts/airflow-restart.sh /usr/local/bin/airflowrestart
COPY ./scripts/airflow-start.sh /usr/local/bin/airflowstart
COPY ./scripts/airflow-stop.sh /usr/local/bin/airflowstop
RUN sed -i "s#{airflow_log_webserver}#$airflow_log_webserver#g" /usr/local/bin/airflowstart && \
    sed -i "s#{airflow_log_scheduler}#$airflow_log_scheduler#g" /usr/local/bin/airflowstart
RUN chmod +x /usr/local/bin/airflowrestart && chmod +x /usr/local/bin/airflowstart && chmod +x /usr/local/bin/airflowstop

## auto start at reboot
RUN echo "airflowstart" >> /init_service

## log rotate
RUN addlogrotate $airflow_log_webserver webserver
RUN addlogrotate $airflow_log_scheduler scheduler
