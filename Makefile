# build basic system image
build_base:
	docker build --no-cache -f ./Dockerfiles/system/centos_base.Dockerfile -t centos_base ./Dockerfiles/system

build_minimal:
	docker build --no-cache -f ./Dockerfiles/system/centos_minimal.Dockerfile -t centos_minimal ./Dockerfiles/system

build_minimal_7:
	docker build --no-cache -f ./Dockerfiles/system/centos_minimal.Dockerfile --build-arg version=7.9.2009 -t centos_minimal_7 ./Dockerfiles/system

# build dev image
build_dev_golang:
	docker build --no-cache -f ./Dockerfiles/dev/centos_dev_golang.Dockerfile -t centos_golang ./Dockerfiles/dev

build_dev_java:
	docker build --no-cache -f ./Dockerfiles/dev/centos_dev_java.Dockerfile -t centos_java ./Dockerfiles/dev

build_dev_java_minimal:
	docker build --no-cache -f ./Dockerfiles/dev/centos_dev_java_minimal.Dockerfile -t centos_java_minimal ./Dockerfiles/dev

build_dev_python:
	docker build --no-cache -f ./Dockerfiles/dev/centos_dev_python.Dockerfile -t centos_python ./Dockerfiles/dev

build_dev_nodejs:
	docker build --no-cache -f ./Dockerfiles/dev/centos_dev_nodejs.Dockerfile -t centos_nodejs ./Dockerfiles/dev

build_dev_full:
	docker build --no-cache -f ./Dockerfiles/dev/centos_dev_full.Dockerfile -t centos_dev_full ./Dockerfiles/dev

# build frontend image
## vue admin
build_vue_admin:
	docker build --no-cache -f ./Dockerfiles/frontend/vue-admin/vue_admin.Dockerfile -t centos_vue ./Dockerfiles/frontend/vue-admin/

run_vue_admin:
	docker run -it -d --hostname test_vue --name dev_vue -p 9527:9527 centos_vue

## ant design
build_ant_design:
	docker build --no-cache -f ./Dockerfiles/frontend/ant-design/ant_design.Dockerfile -t centos_react ./Dockerfiles/frontend/ant-design/

run_ant_design:
	docker run -it -d --hostname test_react --name dev_react -p 8000:8000 centos_react

# build backend image
## mysql
build_mysql:
	docker build --no-cache -f ./Dockerfiles/backend/mysql/mysql.Dockerfile -t centos_mysql ./Dockerfiles/backend/mysql/

run_mysql:
	docker run -it -d --hostname test_mysql --name dev_mysql -p 3306:3306 centos_mysql

## redis
build_redis:
	docker build --no-cache -f ./Dockerfiles/backend/redis/redis.Dockerfile -t centos_redis ./Dockerfiles/backend/redis/

run_redis:
	docker run -d -it --hostname test_redis --name dev_redis -p 6379:6379 centos_redis

## prometheus
build_prometheus:
	docker build --no-cache -f ./Dockerfiles/backend/prometheus/prometheus_pkg.Dockerfile -t centos_prometheus ./Dockerfiles/backend/prometheus/

build_prometheus_compile:
	docker build --no-cache -f ./Dockerfiles/backend/prometheus/prometheus_compile.Dockerfile -t centos_prometheus ./Dockerfiles/backend/prometheus/

run_prometheus:
	docker run -it -d --hostname test_prometheus --name dev_prometheus centos_prometheus

## zookeeper
build_zookeeper:
	docker build --no-cache -f ./Dockerfiles/backend/zookeeper/zookeeper.Dockerfile -t centos_zookeeper ./Dockerfiles/backend/zookeeper/

run_zookeeper:
	docker run -it -d --hostname test_zookeeper --name dev_zookeeper -p 12181:2181 centos_zookeeper

run_zookeeper_cluster:
	docker-compose -f ./deployments/compose/zookeeper/zookeeper_cluster.yml up

remove_zookeeper_cluster:
	docker-compose -f ./deployments/compose/zookeeper/zookeeper_cluster.yml down --volumes

## kafka
build_kafka:
	docker build --network=host --no-cache -f ./Dockerfiles/backend/kafka/kafka_pkg.Dockerfile -t centos_kafka ./Dockerfiles/backend/kafka/

build_kafka_compile:
	docker build --no-cache -f ./Dockerfiles/backend/kafka/kafka_compile.Dockerfile -t centos_kafka ./Dockerfiles/backend/kafka/

run_kafka:
	docker run -it -d --hostname test_kafka --name dev_kafka -p 9092:9092 -e zookeeper_server=172.17.0.1:12181 centos_kafka

run_kafka_cluster:
	docker-compose -f ./deployments/compose/kafka/kafka_cluster.yml up

remove_kafka_cluster:
	docker-compose -f ./deployments/compose/kafka/kafka_cluster.yml down --volumes

## nacos
build_nacos:
	docker build --no-cache -f ./Dockerfiles/backend/nacos/nacos.Dockerfile -t centos_nacos ./Dockerfiles/backend/nacos/

run_nacos_mysql:
	docker-compose -f ./deployments/compose/nacos/nacos_mysql.yml up

remove_nacos_mysql:
	docker-compose -f ./deployments/compose/nacos/nacos_mysql.yml down --volumes

## jenkins
build_jenkins:
	docker build --no-cache -f ./Dockerfiles/backend/jenkins/jenkins.Dockerfile -t centos_jenkins ./Dockerfiles/backend/jenkins/

run_jenkins:
	docker run -it -d --hostname test_jenkins --name dev_jenkins -p 8089:8089 -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/jenkins/.jenkins/workspace:/var/lib/jenkins/.jenkins/workspace centos_jenkins

## git
build_git:
	docker build --no-cache -f ./Dockerfiles/backend/git/git.Dockerfile -t centos_git ./Dockerfiles/backend/git/

run_git:
	docker run -it -d --hostname test_git --name dev_git -p 2022:22 centos_git

# build emr image
## airflow
build_airflow:
	docker build --no-cache -f ./Dockerfiles/emr/airflow/airflow.Dockerfile -t centos_airflow ./Dockerfiles/emr/airflow/

run_airflow:
	docker run -it -d --hostname test_airflow --name dev_airflow -p 8072:8072 centos_airflow

## hdfs
build_hdfs:
	docker build --no-cache -f ./Dockerfiles/emr/hdfs/hdfs.Dockerfile -t centos_hdfs ./Dockerfiles/emr/hdfs/

run_hdfs:
	docker run -d -it --hostname test_hdfs --name dev_hdfs -p 8088:8088 -p 50070:50070 centos_hdfs

## hive
build_hive:
	docker build --no-cache -f ./Dockerfiles/emr/hive/hive.Dockerfile -t centos_hive ./Dockerfiles/emr/hive/

run_hive:
	docker run -d -it --hostname test_hive --name dev_hive -p 8088:8088 -p 50070:50070 -p 10000:10000 -e mysql_host=mysql_host -e mysql_port=3306 -e mysql_db=hive -e mysql_user=root -e mysql_pwd=pwd centos_hive

## hue
build_hue:
	docker build --no-cache -f ./Dockerfiles/emr/hue/hue_base.Dockerfile -t centos_hue_base ./Dockerfiles/emr/hue/
	docker build --no-cache -f ./Dockerfiles/emr/hue/hue.Dockerfile -t centos_hue ./Dockerfiles/emr/hue/

run_hue:
	docker run -d -it --hostname test_hue --name dev_hue -p 8281:8281 -e mysql_host=mysql_host -e mysql_port=3306 -e mysql_db=hive -e mysql_user=root -e mysql_password=pwd centos_hue

## jupyter
build_jupyter:
	docker build --no-cache -f ./Dockerfiles/emr/jupyter/jupyter_base.Dockerfile -t centos_jupyter_base ./Dockerfiles/emr/jupyter/
	docker build --no-cache -f ./Dockerfiles/emr/jupyter/jupyter.Dockerfile -t centos_jupyter ./Dockerfiles/emr/jupyter/

run_jupyter:
	docker run -it -d --hostname test_jupyter --name dev_jupyter -p 8000:8000 centos_jupyter

run_jupyter_lab:
	docker run -it -d --hostname test_jupyter --name dev_jupyter -e component=lab -p 8000:8000 centos_jupyter

# build net image
## xrdp
build_xrdp:
	docker build --network=host --no-cache --platform linux/amd64 -f ./Dockerfiles/net/xrdp/xrdp.Dockerfile -t centos_xrdp ./Dockerfiles/net/xrdp/

run_xrdp:
	docker run -it -d --privileged=true --platform linux/amd64 --hostname test_xrdp --name dev_xrdp -p 3389:3389 -p 7881:7881 centos_xrdp /usr/sbin/init

## easyconnect
build_ec:
	docker build --network=host --no-cache --platform linux/amd64 -f ./Dockerfiles/net/ec/easyconnect.Dockerfile -t centos_ec ./Dockerfiles/net/ec/

run_ec:
	docker run -it -d --privileged=true --platform linux/amd64 --hostname test_ec --name dev_ec -p 3389:3389 -p 7881:7881 centos_ec /usr/sbin/init