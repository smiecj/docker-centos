ARG IMAGE_PYTHON_JAVA
FROM ${IMAGE_PYTHON_JAVA}

ARG module_home
ARG apache_repo
ARG spark_version
ARG spark_hadoop_version

ENV SPARK_MASTER_HOST=localhost
ENV SPARK_MASTER_WEBUI_PORT=8080
ENV SPARK_MASTER_RPC_PORT=7077
ENV SPARK_START=sparkstartall
ENV SPARK_DRIVER_MEMORY=1g
ENV SPARK_EXECUTOR_MEMORY=1g

ENV SPARK_HISTORY_ENABLE=false
ENV SPARK_HISTORY_PORT=18080
ENV SPARK_HISTORY_RETAIN_APP=30
ENV SPARK_LOG_PATH=file:/tmp/spark-events

## config and script
COPY ./conf/ /tmp

## scripts

COPY ./scripts/*.sh /tmp

RUN mv /tmp/spark-restart-all.sh /usr/local/bin/sparkrestartall && \
    mv /tmp/spark-start-all.sh /usr/local/bin/sparkstartall && \
    mv /tmp/spark-stop-all.sh /usr/local/bin/sparkstopall && \
    mv /tmp/spark-restart.sh /usr/local/bin/sparkrestart && \
    mv /tmp/spark-start.sh /usr/local/bin/sparkstart && \
    mv /tmp/spark-stop.sh /usr/local/bin/sparkstop && \
    mv /tmp/spark-not-start.sh /usr/local/bin/sparknotstart && \
    mv /tmp/spark-history-restart.sh /usr/local/bin/sparkhistoryrestart && \
    mv /tmp/spark-history-start.sh /usr/local/bin/sparkhistorystart && \
    mv /tmp/spark-history-stop.sh /usr/local/bin/sparkhistorystop && \

    spark_repo=${apache_repo}/spark && \
    spark_src_folder=spark-${spark_version} && \
    spark_src_pkg=${spark_src_folder}.tgz && \
    spark_src_pkg_url=${apache_repo}/spark/spark-${spark_version}/${spark_src_pkg} && \
    spark_module_folder=spark-${spark_version}-bin-custom-spark && \
    spark_pkg=${spark_module_folder}.tgz && \
    spark_module_home=${module_home}/spark && \
    cd /tmp && curl -LO ${spark_src_pkg_url} && tar -xzvf ${spark_src_pkg} && rm ${spark_src_pkg} && \
    cd ${spark_src_folder} && source /etc/profile && mvn -DskipTests -Dmaven.test.skip=true clean package && \
    echo "[test] mvn build finish" && \
    ./dev/make-distribution.sh --name custom-spark --pip --tgz -Phive -Phive-thriftserver -Pmesos -Pyarn -Dhadoop.version=${spark_hadoop_version} && \
    echo "[test] make dist finish" && \
    mkdir -p ${spark_module_home} && mv ${spark_pkg} ${spark_module_home} && cd .. && rm -r ${spark_src_folder} && \
    cd ${spark_module_home} && tar -xzvf ${spark_pkg} && mv ${spark_module_folder}/* ${spark_module_home} && rm -r ${spark_module_folder} && rm ${spark_pkg} && \
    # maven clean
    rm -rf ~/.m2/repository/* && \

    echo -e """\n\
# spark\n\
export SPARK_HOME=${spark_module_home}\n\
export PATH=\$PATH:\$SPARK_HOME/bin:\$SPARK_HOME/sbin\n\
""" >> /etc/profile && \

## gen ssh key (for multiple worker)
    ssh-keygen -t rsa -N '' -f $HOME/.ssh/id_rsa && \
    cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys && \
    chmod 0600 $HOME/.ssh/authorized_keys && \

## init service
    mv /tmp/init-spark.sh ${spark_module_home}/ && \
    mv /tmp/spark-env.sh.template ${spark_module_home}/conf/ && \
    mv /tmp/spark-defaults.conf.template ${spark_module_home}/conf/ && \
    sed -i "s#{spark_module_home}#${spark_module_home}#g" ${spark_module_home}/init-spark.sh && \
    sed -i "s#{spark_module_home}#${spark_module_home}#g" /usr/local/bin/spark* && \
    chmod +x /usr/local/bin/spark* && \
    echo "/init_ssh_service" >> /init_service && \
    echo "sh ${spark_module_home}/init-spark.sh && nohup \${SPARK_START} > /dev/null 2>&1 &" >> /init_service

# submit: ./bin/spark-submit --class org.apache.spark.examples.SparkPi --master spark://localhost:7077 --deploy-mode cluster --executor-memory 1G --executor-cores 1 ./examples/jars/spark-examples.jar 80