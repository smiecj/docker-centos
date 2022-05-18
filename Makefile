# build basic system image
build_base:
	docker build --no-cache -f ./Dockerfiles/system/centos_base.Dockerfile -t centos_base ./Dockerfiles/system

build_minimal:
	docker build --no-cache -f ./Dockerfiles/system/centos_minimal.Dockerfile -t centos_minimal ./Dockerfiles/system

build_minimal_7:
	docker build --no-cache -f ./Dockerfiles/system/centos_minimal.Dockerfile --build-arg version=7.9.2009 -t centos_minimal ./Dockerfiles/system

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

run_zookeeper_cluster:
	docker-compose -f ./deployments/compose/zookeeper/zookeeper_cluster.yml up

remove_zookeeper_cluster:
	docker-compose -f ./deployments/compose/zookeeper/zookeeper_cluster.yml down --volumes

## nacos
build_nacos:
	docker build --no-cache -f ./Dockerfiles/backend/nacos/nacos.Dockerfile -t centos_nacos ./Dockerfiles/backend/nacos/

run_nacos_mysql:
	docker-compose -f ./deployments/compose/nacos/nacos_mysql.yml up

remove_nacos_mysql:
	docker-compose -f ./deployments/compose/nacos/nacos_mysql.yml down --volumes

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
