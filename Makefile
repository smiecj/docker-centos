ROOT := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
include $(ROOT)/Makefile.vars

hello:
	@echo "hello docker centos!"
	@if [[ "${REPO}" != "" ]]; then echo "repo: ${REPO}"; fi

# build basic system image
build_base:
	docker build --no-cache -f ./Dockerfiles/system/centos_base.Dockerfile -t ${BASE_IMAGE} ./Dockerfiles/system

build_minimal:
	docker build --no-cache -f ./Dockerfiles/system/centos_minimal.Dockerfile -t ${MINIMAL_IMAGE} ./Dockerfiles/system

build_minimal_7:
	docker build --no-cache -f ./Dockerfiles/system/centos_minimal.Dockerfile --build-arg version=7.9.2009 -t ${MINIMAL_IMAGE_7} ./Dockerfiles/system

# build dev image
build_dev_golang:
	docker build --build-arg BASE_IMAGE=${BASE_IMAGE} --no-cache -f ./Dockerfiles/dev/centos_dev_golang.Dockerfile -t ${GO_IMAGE} ./Dockerfiles/dev

build_dev_java:
	docker build --build-arg BASE_IMAGE=${BASE_IMAGE} --no-cache -f ./Dockerfiles/dev/centos_dev_java.Dockerfile -t ${JAVA_IMAGE} ./Dockerfiles/dev

build_dev_java_17:
	docker build --build-arg BASE_IMAGE=${BASE_IMAGE} --build-arg jdk_new_version=17 --no-cache -f ./Dockerfiles/dev/centos_dev_java.Dockerfile -t ${JAVA_IMAGE} ./Dockerfiles/dev

build_dev_java_minimal:
	docker build --build-arg MINIMAL_IMAGE=${MINIMAL_IMAGE} --no-cache -f ./Dockerfiles/dev/centos_dev_java_minimal.Dockerfile -t centos_java_minimal:${IMAGE_TAG} ./Dockerfiles/dev

build_dev_python:
	docker build --build-arg BASE_IMAGE=${BASE_IMAGE} --no-cache -f ./Dockerfiles/dev/centos_dev_python.Dockerfile -t ${PYTHON_IMAGE} ./Dockerfiles/dev

build_dev_nodejs:
	docker build --build-arg BASE_IMAGE=${BASE_IMAGE} --no-cache -f ./Dockerfiles/dev/centos_dev_nodejs.Dockerfile -t ${NODEJS_IMAGE} ./Dockerfiles/dev

build_dev_full:
	docker build --build-arg BASE_IMAGE=${BASE_IMAGE} \
	--build-arg JAVA_IMAGE=${JAVA_IMAGE} --build-arg GO_IMAGE=${GO_IMAGE} \
	--build-arg NODEJS_IMAGE=${NODEJS_IMAGE} --build-arg PYTHON_IMAGE=${PYTHON_IMAGE} \
	--no-cache -f ./Dockerfiles/dev/centos_dev_full.Dockerfile -t ${DEV_FULL_IMAGE} \
	./Dockerfiles/dev

run_dev_full:
	docker run -it -d --hostname test_dev --name dev -p 22022:22 ${DEV_FULL_IMAGE}

build_dev_rust:
	docker build --no-cache -f ./Dockerfiles/dev/centos_dev_rust.Dockerfile -t ${RUST_IMAGE} ./Dockerfiles/dev

build_dev_all: build_base build_dev_golang build_dev_java build_dev_python build_dev_nodejs build_dev_full

build_code_server:
	docker buildx build --build-arg DEV_FULL_IMAGE=${DEV_FULL_IMAGE} --no-cache -f ./Dockerfiles/dev/code-server/code_server.Dockerfile -t ${CODE_SERVER_IMAGE} ./Dockerfiles/dev/code-server

run_code_server:
	docker run -it -d --hostname test_code_server --name dev_code_server -p 8080:8080 ${CODE_SERVER_IMAGE}

# build frontend image
## vue admin
build_vue_admin:
	docker build --build-arg NODEJS_IMAGE=${NODEJS_IMAGE} --no-cache -f ./Dockerfiles/frontend/vue-admin/vue_admin.Dockerfile -t ${VUE_IMAGE} ./Dockerfiles/frontend/vue-admin/

run_vue_admin:
	docker run -it -d --hostname test_vue --name dev_vue -p 9527:9527 ${VUE_IMAGE}

## ant design
build_ant_design:
	docker build --build-arg NODEJS_IMAGE=${NODEJS_IMAGE} --no-cache -f ./Dockerfiles/frontend/ant-design/ant_design.Dockerfile -t ${REACT_IMAGE} ./Dockerfiles/frontend/ant-design/

run_ant_design:
	docker run -it -d --hostname test_react --name dev_react -p 8000:8000 ${REACT_IMAGE}

# build backend image
## mysql
build_mysql:
	docker build --build-arg MINIMAL_IMAGE=${MINIMAL_IMAGE} --no-cache -f ./Dockerfiles/backend/mysql/mysql.Dockerfile -t ${MYSQL_IMAGE} ./Dockerfiles/backend/mysql/

build_mysql_compile:
	docker build --build-arg BASE_IMAGE=${BASE_IMAGE} --no-cache -f ./Dockerfiles/backend/mysql/mysql_compile.Dockerfile -t ${MYSQL_IMAGE} ./Dockerfiles/backend/mysql/

run_mysql:
	docker run -it -d --hostname test_mysql --name dev_mysql -p 3306:3306 ${MYSQL_IMAGE}

## mongo
build_mongo:
	docker build --build-arg PYTHON_IMAGE=${PYTHON_IMAGE} --no-cache -f ./Dockerfiles/backend/mongo/mongo.Dockerfile -t ${MONGO_IMAGE} ./Dockerfiles/backend/mongo/

build_mongo_compile:
	docker build --build-arg PYTHON_IMAGE=${PYTHON_IMAGE} --no-cache -f ./Dockerfiles/backend/mongo/mongo_compile.Dockerfile -t ${MONGO_IMAGE} ./Dockerfiles/backend/mongo/

run_mongo:
	docker run -it -d --hostname test_mongo --name dev_mongo -p 27017:27017 ${MONGO_IMAGE}

## redis
build_redis:
	docker build --build-arg BASE_IMAGE=${BASE_IMAGE} --no-cache -f ./Dockerfiles/backend/redis/redis.Dockerfile -t ${REDIS_IMAGE} ./Dockerfiles/backend/redis/

run_redis:
	docker run -d -it --hostname test_redis --name dev_redis -p 6379:6379 ${REDIS_IMAGE}

## prometheus
build_prometheus:
	docker build --build-arg MINIMAL_IMAGE=${MINIMAL_IMAGE} --no-cache -f ./Dockerfiles/backend/prometheus/prometheus.Dockerfile -t ${PROMETHEUS_IMAGE} ./Dockerfiles/backend/prometheus/

build_prometheus_compile:
	docker build --build-arg NODEJS_IMAGE=${NODEJS_IMAGE} --build-arg GO_IMAGE=${GO_IMAGE} --no-cache -f ./Dockerfiles/backend/prometheus/prometheus_compile.Dockerfile -t ${PROMETHEUS_IMAGE} ./Dockerfiles/backend/prometheus/

run_prometheus:
	docker run -it -d --hostname test_prometheus --name dev_prometheus -p 3000:3000 -p 3001:3001 -p 9001:9001 ${PROMETHEUS_IMAGE}

## zookeeper
build_zookeeper:
	docker build --build-arg JAVA_IMAGE=${JAVA_IMAGE} --no-cache -f ./Dockerfiles/backend/zookeeper/zookeeper.Dockerfile -t ${ZOOKEEPER_IMAGE} ./Dockerfiles/backend/zookeeper/

run_zookeeper:
	docker run -it -d --hostname test_zookeeper --name dev_zookeeper -p 12181:2181 ${ZOOKEEPER_IMAGE}

run_zookeeper_cluster:
	ZOOKEEPER_IMAGE=${ZOOKEEPER_IMAGE} docker-compose -f ./deployments/compose/zookeeper/zookeeper_cluster.yml up -d

remove_zookeeper_cluster:
	ZOOKEEPER_IMAGE=${ZOOKEEPER_IMAGE} docker-compose -f ./deployments/compose/zookeeper/zookeeper_cluster.yml down --volumes

## kafka
build_kafka:
	docker build --build-arg JAVA_IMAGE=${JAVA_IMAGE} --network=host --no-cache -f ./Dockerfiles/backend/kafka/kafka.Dockerfile -t ${KAFKA_IMAGE} ./Dockerfiles/backend/kafka/

build_kafka_compile:
	docker build --build-arg JAVA_IMAGE=${JAVA_IMAGE} --no-cache -f ./Dockerfiles/backend/kafka/kafka_compile.Dockerfile -t ${KAFKA_IMAGE} ./Dockerfiles/backend/kafka/

run_kafka:
	docker run -it -d --hostname test_kafka --name dev_kafka -p 9092:9092 -e zookeeper_server=172.17.0.1:12181 ${KAFKA_IMAGE}

run_kafka_cluster:
	ZOOKEEPER_IMAGE=${ZOOKEEPER_IMAGE} KAFKA_IMAGE=${KAFKA_IMAGE} docker-compose -f ./deployments/compose/kafka/kafka_cluster.yml up -d

remove_kafka_cluster:
	ZOOKEEPER_IMAGE=${ZOOKEEPER_IMAGE} KAFKA_IMAGE=${KAFKA_IMAGE} docker-compose -f ./deployments/compose/kafka/kafka_cluster.yml down --volumes

## nacos
build_nacos:
	docker build --build-arg JAVA_IMAGE=${JAVA_IMAGE} --no-cache -f ./Dockerfiles/backend/nacos/nacos.Dockerfile -t ${NACOS_IMAGE} ./Dockerfiles/backend/nacos/

run_nacos_mysql:
	NACOS_IMAGE=${NACOS_IMAGE} MYSQL_IMAGE=${MYSQL_IMAGE} docker-compose -f ./deployments/compose/nacos/nacos_mysql.yml up -d

remove_nacos_mysql:
	NACOS_IMAGE=${NACOS_IMAGE} MYSQL_IMAGE=${MYSQL_IMAGE} docker-compose -f ./deployments/compose/nacos/nacos_mysql.yml down --volumes

## jenkins
build_jenkins:
	docker build --build-arg JAVA_IMAGE=${JAVA_IMAGE} --no-cache -f ./Dockerfiles/backend/jenkins/jenkins.Dockerfile -t centos_jenkins ./Dockerfiles/backend/jenkins/

run_jenkins:
	docker run -it -d --hostname test_jenkins --name dev_jenkins -p 8089:8089 -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/jenkins/.jenkins/workspace:/var/lib/jenkins/.jenkins/workspace centos_jenkins

## git
build_git:
	docker build --build-arg MINIMAL_IMAGE_7=${MINIMAL_IMAGE_7} --no-cache -f ./Dockerfiles/backend/git/git.Dockerfile -t centos_git ./Dockerfiles/backend/git/

run_git:
	docker run -it -d --hostname test_git --name dev_git -p 2022:22 centos_git

# build emr image
## airflow
build_airflow:
	docker build --no-cache -f ./Dockerfiles/emr/airflow/airflow.Dockerfile -t ${AIRFLOW_IMAGE} ./Dockerfiles/emr/airflow/

run_airflow:
	docker run -it -d --hostname test_airflow --name dev_airflow -p 8072:8072 ${AIRFLOW_IMAGE}

## hdfs
build_hdfs:
	docker build --build-arg JAVA_IMAGE=${JAVA_IMAGE} --build-arg PYTHON_IMAGE=${PYTHON_IMAGE} --no-cache -f ./Dockerfiles/emr/hdfs/hdfs.Dockerfile -t ${HDFS_IMAGE} ./Dockerfiles/emr/hdfs/

build_hdfs_full:
	docker build --build-arg KNOX_IMAGE=${KNOX_IMAGE} --build-arg HIVE_IMAGE=${HIVE_IMAGE} --build-arg HDFS_IMAGE=${HDFS_IMAGE} --no-cache -f ./Dockerfiles/emr/hdfs/hdfs_full.Dockerfile -t ${HDFS_FULL_IMAGE} ./Dockerfiles/emr/hdfs/

### build all hdfs cluster need image
build_hdfs_cluster: build_dev_all build_hdfs build_hive build_knox build_hdfs_full

run_hdfs:
	docker run -d -it --hostname test_hdfs --name dev_hdfs -p 8088:8088 -p 50070:50070 ${HDFS_IMAGE}

run_hdfs_cluster:
	HDFS_FULL_IMAGE=${HDFS_FULL_IMAGE} MYSQL_IMAGE=${MYSQL_IMAGE} docker-compose -f ./deployments/compose/hdfs/hdfs_cluster.yml up -d

remove_hdfs_cluster:
	HDFS_FULL_IMAGE=${HDFS_FULL_IMAGE} MYSQL_IMAGE=${MYSQL_IMAGE} docker-compose -f ./deployments/compose/hdfs/hdfs_cluster.yml down --volumes

## hive
build_hive:
	docker build --build-arg HDFS_IMAGE=${HDFS_IMAGE} --no-cache -f ./Dockerfiles/emr/hive/hive.Dockerfile -t ${HIVE_IMAGE} ./Dockerfiles/emr/hive/

run_hive:
	docker run -d -it --hostname test_hive --name dev_hive -p 8088:8088 -p 50070:50070 -p 10000:10000 -e mysql_host=mysql_host -e mysql_port=3306 -e mysql_db=hive -e mysql_user=root -e mysql_pwd=pwd ${HIVE_IMAGE}

## hue
build_hue:
	docker build --build-arg JAVA_IMAGE=${JAVA_IMAGE} --build-arg NODEJS_IMAGE=${NODEJS_IMAGE} --build-arg MINIMAL_IMAGE_7=${MINIMAL_IMAGE_7} --no-cache -f ./Dockerfiles/emr/hue/hue_base.Dockerfile -t ${HUE_BASE_IMAGE} ./Dockerfiles/emr/hue/
	docker build --build-arg HUE_BASE_IMAGE=${HUE_BASE_IMAGE} --no-cache -f ./Dockerfiles/emr/hue/hue.Dockerfile -t ${HUE_IMAGE} ./Dockerfiles/emr/hue/

run_hue:
	HUE_IMAGE=${HUE_IMAGE} MYSQL_IMAGE=${MYSQL_IMAGE} docker-compose -f ./deployments/compose/hue/hue.yml up -d

remove_hue:
	HUE_IMAGE=${HUE_IMAGE} MYSQL_IMAGE=${MYSQL_IMAGE} docker-compose -f ./deployments/compose/hue/hue.yml down --volumes

## jupyter
build_jupyter:
	docker build --build-arg NODEJS_IMAGE=${NODEJS_IMAGE} --build-arg PYTHON_IMAGE=${PYTHON_IMAGE} --build-arg BASE_IMAGE=${BASE_IMAGE} --no-cache -f ./Dockerfiles/emr/jupyter/jupyter_base.Dockerfile -t ${JUPYTER_BASE_IMAGE} ./Dockerfiles/emr/jupyter/
	docker build --build-arg JUPYTER_BASE_IMAGE=${JUPYTER_BASE_IMAGE} --no-cache -f ./Dockerfiles/emr/jupyter/jupyter.Dockerfile -t ${JUPYTER_IMAGE} ./Dockerfiles/emr/jupyter/

build_jupyter_2:
	docker build --build-arg NODEJS_IMAGE=${NODEJS_IMAGE} --build-arg PYTHON_IMAGE=${PYTHON_IMAGE} --build-arg BASE_IMAGE=${BASE_IMAGE} --no-cache -f ./Dockerfiles/emr/jupyter/jupyter_base.Dockerfile -t ${JUPYTER_BASE_IMAGE} ./Dockerfiles/emr/jupyter/
	docker build --build-arg JUPYTER_BASE_IMAGE=${JUPYTER_BASE_IMAGE} --build-arg jupyter_version=2 --no-cache -f ./Dockerfiles/emr/jupyter/jupyter.Dockerfile -t ${JUPYTER_2_IMAGE} ./Dockerfiles/emr/jupyter/

run_jupyter:
	docker run -it -d --hostname test_jupyter --name dev_jupyter -p 8000:8000 ${JUPYTER_IMAGE}

run_jupyter_lab:
	docker run -it -d --hostname test_jupyter --name dev_jupyter -e component=lab -p 8000:8000 ${JUPYTER_IMAGE}

run_jupyter_lab2:
	docker run -it -d --hostname test_jupyter --name dev_jupyter -e component=lab -p 8000:8000 ${JUPYTER_2_IMAGE}

## presto
build_presto:
	docker build --build-arg JAVA_IMAGE=${JAVA_IMAGE} --build-arg PYTHON_IMAGE=${--build-arg BASE_IMAGE=${BASE_IMAGE}} --build-arg BASE_IMAGE=${BASE_IMAGE} --no-cache -f ./Dockerfiles/emr/presto/presto_base.Dockerfile -t ${PRESTO_BASE_IMAGE} ./Dockerfiles/emr/presto/
	docker build --build-arg PRESTO_BASE_IMAGE=${PRESTO_BASE_IMAGE} --no-cache -f ./Dockerfiles/emr/presto/presto.Dockerfile -t ${PRESTO_IMAGE} ./Dockerfiles/emr/presto/

run_presto:
	docker run -d -it --hostname test_presto --name dev_presto -p 8080:8080 -e HIVE_METASTORE_URL=hive_metastore_host:hive_metastore_port -e HADOOP_CONF_DIR=/etc/hadoop/conf -v /etc/hadoop/conf:/etc/hadoop/conf ${PRESTO_IMAGE}

## knox
build_knox:
	docker build --build-arg JAVA_IMAGE=${JAVA_IMAGE} --no-cache -f ./Dockerfiles/emr/knox/knox.Dockerfile -t ${KNOX_IMAGE} ./Dockerfiles/emr/knox/

build_knox_compile:
	docker build --build-arg JAVA_IMAGE=${JAVA_IMAGE} --no-cache -f ./Dockerfiles/emr/knox/knox_compile.Dockerfile -t ${KNOX_IMAGE} ./Dockerfiles/emr/knox/

run_knox:
	docker run -d -it --hostname test-knox --name dev_knox -p 8443:8443 ${KNOX_IMAGE}

# build net image
## xrdp
build_xrdp:
	docker build --network=host --no-cache --platform linux/amd64 -f ./Dockerfiles/net/xrdp/xrdp.Dockerfile -t ${XRDP_IMAGE} ./Dockerfiles/net/xrdp/

run_xrdp:
	docker run -it -d --privileged=true --platform linux/amd64 --hostname test_xrdp --name dev_xrdp -p 3389:3389 -p 7881:7881 ${XRDP_IMAGE} /usr/sbin/init

## easyconnect
build_ec:
	docker build --build-arg XRDP_IMAGE=${XRDP_IMAGE} --network=host --no-cache --platform linux/amd64 -f ./Dockerfiles/net/ec/easyconnect.Dockerfile -t ${EC_IMAGE} ./Dockerfiles/net/ec/

run_ec:
	docker run -it -d --privileged=true --platform linux/amd64 --hostname test_ec --name dev_ec -p 3389:3389 -p 7881:7881 ${EC_IMAGE} /usr/sbin/init