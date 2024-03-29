ROOT := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
include $(ROOT)/Makefile.vars
include $(ROOT)/Makefile.vars.repo
export

hello:
	@echo "hello docker centos!"
	@if [[ "${REPO}" != "" ]]; then echo "repo: ${REPO}"; fi

# build basic system image
build_base:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/system/centos_base.Dockerfile ${IMAGE_BASE} ./Dockerfiles/system

build_minimal:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/system/centos_minimal.Dockerfile ${IMAGE_MINIMAL} ./Dockerfiles/system

# build dev image
build_dev_golang:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/dev/lang/golang.Dockerfile ${IMAGE_GO} ./Dockerfiles/dev/lang

build_dev_java:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/dev/lang/java.Dockerfile ${IMAGE_JAVA} ./Dockerfiles/dev/lang

build_dev_java_minimal:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/dev/lang/java_minimal.Dockerfile centos_java_minimal ./Dockerfiles/dev/lang

build_dev_python:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/dev/lang/python.Dockerfile ${IMAGE_PYTHON} ./Dockerfiles/dev/lang

build_dev_nodejs:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/dev/lang/nodejs.Dockerfile ${IMAGE_NODEJS} ./Dockerfiles/dev/lang

## mix dev image
build_dev_python_java:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/dev/lang/mix_python_java.Dockerfile ${IMAGE_PYTHON_JAVA} ./Dockerfiles/dev/lang

build_dev_go_nodejs:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/dev/lang/mix_go_nodejs.Dockerfile ${IMAGE_GO_NODEJS} ./Dockerfiles/dev/lang

build_dev_python_nodejs:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/dev/lang/mix_python_nodejs.Dockerfile ${IMAGE_PYTHON_NODEJS} ./Dockerfiles/dev/lang

build_dev_java_nodejs:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/dev/lang/mix_java_nodejs.Dockerfile ${IMAGE_JAVA_NODEJS} ./Dockerfiles/dev/lang

build_dev_python_java_nodejs:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/dev/lang/mix_python_nodejs_java.Dockerfile ${IMAGE_PYTHON_JAVA_NODEJS} ./Dockerfiles/dev/lang

build_dev_full:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/dev/lang/full.Dockerfile ${IMAGE_DEV_FULL} ./Dockerfiles/dev/lang

run_dev_full:
	docker run -it -d --hostname test_dev --name dev -p 22022:22 ${IMAGE_DEV_FULL}

build_dev_rust:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/dev/lang/rust.Dockerfile ${IMAGE_RUST} ./Dockerfiles/dev/lang

## code server
build_code_server:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/dev/code-server/code_server.Dockerfile ${IMAGE_CODE_SERVER} ./Dockerfiles/dev/code-server

run_code_server:
	docker run -it -d --hostname test_code_server --name dev_code_server -p 8080:8080 ${IMAGE_CODE_SERVER}

## navidrome
build_navidrome:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/dev/navidrome/navidrome.Dockerfile ${IMAGE_NAVIDROME} ./Dockerfiles/dev/navidrome

run_navidrome:
	bash ${compose_script} run ./deployments/compose/navidrome/navidrome.yml

remove_navidrome:
	bash ${compose_script} remove ./deployments/compose/navidrome/navidrome.yml

## oauth server
build_oauth_server:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/dev/oauth/oauth_go.Dockerfile ${IMAGE_OAUTH_SERVER} ./Dockerfiles/dev/oauth

run_oauth_server:
	docker run -it -d --hostname test_oauth --name dev_oauth -e HOST=localhost -e HOST_SERVER_PORT=19096 -e HOST_CLIENT_PORT=19094 -p 19094:9094 -p 19096:9096 ${IMAGE_OAUTH_SERVER}

# build frontend image
## vue admin
build_vue_admin:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/frontend/vue-admin/vue_admin.Dockerfile ${IMAGE_VUE} ./Dockerfiles/frontend/vue-admin/

run_vue_admin:
	docker run -it -d --hostname test_vue --name dev_vue -p 9527:9527 ${IMAGE_VUE}

## ant design
build_ant_design:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/frontend/ant-design/ant_design.Dockerfile ${IMAGE_REACT} ./Dockerfiles/frontend/ant-design/

run_ant_design:
	docker run -it -d --hostname test_react --name dev_react -p 8000:8000 ${IMAGE_REACT}

# build backend image
## mysql
build_mysql:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/backend/mysql/mysql.Dockerfile ${IMAGE_MYSQL} ./Dockerfiles/backend/mysql/

build_mysql_compile:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/backend/mysql/mysql_compile.Dockerfile ${IMAGE_MYSQL} ./Dockerfiles/backend/mysql/

run_mysql:
	docker run -it -d --hostname test_mysql --name dev_mysql -p 3306:3306 ${IMAGE_MYSQL}

## pgsql
build_pgsql:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/backend/postgresql/pgsql.Dockerfile ${IMAGE_PGSQL} ./Dockerfiles/backend/postgresql/

build_pgsql_compile:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/backend/postgresql/pgsql_compile.Dockerfile ${IMAGE_PGSQL} ./Dockerfiles/backend/postgresql/

run_pgsql:
	docker run -it -d --hostname test_pgsql --name dev_pgsql -p 5432:5432 ${IMAGE_PGSQL}

## mongo
build_mongo:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/backend/mongo/mongo.Dockerfile ${IMAGE_MONGO} ./Dockerfiles/backend/mongo/

build_mongo_compile:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/backend/mongo/mongo_compile.Dockerfile ${IMAGE_MONGO} ./Dockerfiles/backend/mongo/

run_mongo:
	docker run -it -d --hostname test_mongo --name dev_mongo -p 27017:27017 ${IMAGE_MONGO}

## redis
build_redis:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/backend/redis/redis.Dockerfile ${IMAGE_REDIS} ./Dockerfiles/backend/redis/

run_redis:
	docker run -d -it --hostname test_redis --name dev_redis -p 6379:6379 ${IMAGE_REDIS}

## prometheus
build_prometheus:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/backend/prometheus/prometheus.Dockerfile ${IMAGE_PROMETHEUS} ./Dockerfiles/backend/prometheus/

build_prometheus_compile:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/backend/prometheus/prometheus_compile.Dockerfile ${IMAGE_PROMETHEUS} ./Dockerfiles/backend/prometheus/

run_prometheus:
	docker run -it -d --hostname test_prometheus --name dev_prometheus -p 3001:3001 -p 9001:9001 ${IMAGE_PROMETHEUS}

run_prometheus_grafana:
	bash ${compose_script} run ./deployments/compose/prometheus/prometheus_grafana.yml

remove_prometheus_grafana:
	bash ${compose_script} remove ./deployments/compose/prometheus/prometheus_grafana.yml

## grafana
build_grafana:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/backend/grafana/grafana.Dockerfile ${IMAGE_GRAFANA} ./Dockerfiles/backend/grafana/

build_grafana_compile:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/backend/grafana/grafana_compile.Dockerfile ${IMAGE_GRAFANA} ./Dockerfiles/backend/grafana/

run_grafana:
	docker run -it -d --hostname test_grafana --name dev_grafana -p 3000:3000 ${IMAGE_GRAFANA}

## zookeeper
build_zookeeper:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/backend/zookeeper/zookeeper.Dockerfile ${IMAGE_ZOOKEEPER} ./Dockerfiles/backend/zookeeper/

build_zookeeper_compile:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/backend/zookeeper/zookeeper_compile.Dockerfile ${IMAGE_ZOOKEEPER} ./Dockerfiles/backend/zookeeper/

run_zookeeper:
	docker run -it -d --hostname test_zookeeper --name dev_zookeeper -p 12181:2181 ${IMAGE_ZOOKEEPER}

run_zookeeper_cluster:
	bash ${compose_script} run ./deployments/compose/zookeeper/zookeeper_cluster.yml

remove_zookeeper_cluster:
	bash ${compose_script} remove ./deployments/compose/zookeeper/zookeeper_cluster.yml

## kafka
build_kafka:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/backend/kafka/kafka.Dockerfile ${IMAGE_KAFKA} ./Dockerfiles/backend/kafka/

build_kafka_compile:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/backend/kafka/kafka_compile.Dockerfile ${IMAGE_KAFKA} ./Dockerfiles/backend/kafka/

run_kafka:
	docker run -it -d --hostname test_kafka --name dev_kafka -p 9092:9092 -e zookeeper_server=172.17.0.1:12181 ${IMAGE_KAFKA}

run_kafka_cluster:
	bash ${compose_script} run ./deployments/compose/kafka/kafka_cluster.yml

remove_kafka_cluster:
	bash ${compose_script} remove ./deployments/compose/kafka/kafka_cluster.yml

build_efak:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/backend/kafka-eagle/efak.Dockerfile ${IMAGE_EFAK} ./Dockerfiles/backend/kafka-eagle/

run_kafka_efak:
	bash ${compose_script} run ./deployments/compose/kafka/kafka_cluster_efak.yml

remove_kafka_efak:
	bash ${compose_script} remove ./deployments/compose/kafka/kafka_cluster_efak.yml

## nacos
build_nacos:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/backend/nacos/nacos.Dockerfile ${IMAGE_NACOS} ./Dockerfiles/backend/nacos/

run_nacos_mysql:
	bash ${compose_script} run ./deployments/compose/nacos/nacos_mysql.yml

remove_nacos_mysql:
	bash ${compose_script} remove ./deployments/compose/nacos/nacos_mysql.yml

## apollo
build_apollo:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/backend/apollo/apollo.Dockerfile ${IMAGE_APOLLO} ./Dockerfiles/backend/apollo/

run_apollo:
	bash ${compose_script} run ./deployments/compose/apollo/apollo.yml

remove_apollo:
	bash ${compose_script} remove ./deployments/compose/apollo/apollo.yml

## jenkins
build_jenkins:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/backend/jenkins/jenkins.Dockerfile ${IMAGE_JENKINS} ./Dockerfiles/backend/jenkins/

run_jenkins:
	docker run -it -d --hostname test_jenkins --name dev_jenkins -p 8089:8089 -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/jenkins/.jenkins/workspace:/var/lib/jenkins/.jenkins/workspace ${IMAGE_JENKINS}

## git
build_git:
	docker build --build-arg MINIMAL_IMAGE_7=${MINIMAL_IMAGE_7} --no-cache -f ./Dockerfiles/backend/git/git.Dockerfile -t centos_git ./Dockerfiles/backend/git/

run_git:
	docker run -it -d --hostname test_git --name dev_git -p 2022:22 centos_git

## superset
build_superset:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/backend/superset/superset.Dockerfile ${IMAGE_SUPERSET} ./Dockerfiles/backend/superset/

run_superset:
	docker run -it -d --hostname test_superset --name dev_superset -p 8088:8088 ${IMAGE_SUPERSET}

## wordpress
build_wordpress:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/backend/wordpress/wordpress.Dockerfile ${IMAGE_WORDPRESS} ./Dockerfiles/backend/wordpress/

run_wordpress:
	docker run -it -d --hostname test_wordpress --name dev_wordpress -p 8000:80 ${IMAGE_WORDPRESS}

## nginx
build_nginx:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/backend/nginx/nginx.Dockerfile ${IMAGE_NGINX} ./Dockerfiles/backend/nginx/

run_nginx:
	docker run -it -d --hostname test_nginx --name dev_nginx -p 10080:80 ${IMAGE_NGINX}

# build emr image
## azkaban
build_azkaban:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/emr/azkaban/azkaban.Dockerfile ${IMAGE_AZKABAN} ./Dockerfiles/emr/azkaban/

run_azkaban:
	bash ${compose_script} run ./deployments/compose/azkaban/azkaban.yml

remove_azkaban:
	bash ${compose_script} remove ./deployments/compose/azkaban/azkaban.yml

## dolphinscheduler
build_dolphinscheduler:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/emr/dolphinscheduler/dolphinscheduler.Dockerfile ${IMAGE_DOLPHINSCHEDULER} ./Dockerfiles/emr/dolphinscheduler/

build_dolphinscheduler_compile:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/emr/dolphinscheduler/dolphinscheduler_compile.Dockerfile ${IMAGE_DOLPHINSCHEDULER} ./Dockerfiles/emr/dolphinscheduler/

## prefect
build_prefect:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/emr/prefect/prefect.Dockerfile ${IMAGE_PREFECT} ./Dockerfiles/emr/prefect/

run_prefect:
	docker run -d -it --hostname test_prefect --name dev_prefect -e API_URL=http://localhost:3000/api -p 3000:3000 ${IMAGE_PREFECT}

## datalink
build_datalink:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/emr/datalink/datalink.Dockerfile ${IMAGE_DATALINK} ./Dockerfiles/emr/datalink/

run_datalink_singleton:
	bash ${compose_script} run ./deployments/compose/datalink/datalink_singleton.yml

remove_datalink_singleton:
	bash ${compose_script} remove ./deployments/compose/datalink/datalink_singleton.yml

run_datalink_cluster:
	bash ${compose_script} run ./deployments/compose/datalink/datalink_cluster.yml

remove_datalink_cluster:
	bash ${compose_script} remove ./deployments/compose/datalink/datalink_cluster.yml

build_druid:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/emr/druid/druid.Dockerfile ${IMAGE_DRUID} ./Dockerfiles/emr/druid/

## airflow
build_airflow:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/emr/airflow/airflow.Dockerfile ${IMAGE_AIRFLOW} ./Dockerfiles/emr/airflow/

run_airflow:
	docker run -it -d --hostname test_airflow --name dev_airflow -p 8072:8072 ${IMAGE_AIRFLOW}

run_airflow_singleton:
	bash ${compose_script} run ./deployments/compose/airflow/airflow_singleton.yml

remove_airflow_singleton:
	bash ${compose_script} remove ./deployments/compose/airflow/airflow_singleton.yml

run_airflow_cluster:
	bash ${compose_script} run ./deployments/compose/airflow/airflow_cluster.yml

remove_airflow_cluster:
	bash ${compose_script} remove ./deployments/compose/airflow/airflow_cluster.yml

## flink
build_flink:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/emr/flink/flink.Dockerfile ${IMAGE_FLINK} ./Dockerfiles/emr/flink/

build_flink_compile:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/emr/flink/flink_compile.Dockerfile ${IMAGE_FLINK} ./Dockerfiles/emr/flink/

run_flink:
	bash ${compose_script} run ./deployments/compose/flink/flink_cluster.yml

remove_flink:
	bash ${compose_script} remove ./deployments/compose/flink/flink_cluster.yml

## spark
build_spark:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/emr/spark/spark.Dockerfile ${IMAGE_SPARK} ./Dockerfiles/emr/spark/

build_spark_compile:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/emr/spark/spark_compile.Dockerfile ${IMAGE_SPARK} ./Dockerfiles/emr/spark/

run_spark_singleton:
	bash ${compose_script} run ./deployments/compose/spark/spark_singleton.yml

remove_spark_singleton:
	bash ${compose_script} remove ./deployments/compose/spark/spark_singleton.yml

run_spark_cluster:
	bash ${compose_script} run ./deployments/compose/spark/spark_cluster.yml

remove_spark_cluster:
	bash ${compose_script} remove ./deployments/compose/spark/spark_cluster.yml

## hdfs
build_hdfs:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/emr/hdfs/hdfs.Dockerfile ${IMAGE_HDFS} ./Dockerfiles/emr/hdfs/

build_hdfs_full:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/emr/hdfs/hdfs_full.Dockerfile ${IMAGE_HDFS_FULL} ./Dockerfiles/emr/hdfs/

run_hdfs:
	docker run -d -it --hostname test_hdfs --name dev_hdfs -p 8088:8088 -p 50070:50070 ${IMAGE_HDFS}

run_hdfs_cluster:
	bash ${compose_script} run ./deployments/compose/hdfs/hdfs_cluster.yml

remove_hdfs_cluster:
	bash ${compose_script} remove ./deployments/compose/hdfs/hdfs_cluster.yml

## hive
build_hive:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/emr/hive/hive.Dockerfile ${IMAGE_HIVE} ./Dockerfiles/emr/hive/

run_hive:
	docker run -d -it --hostname test_hive --name dev_hive -p 8088:8088 -p 50070:50070 -p 10000:10000 -e mysql_host=mysql_host -e mysql_port=3306 -e mysql_db=hive -e mysql_user=root -e mysql_pwd=pwd ${IMAGE_HIVE}

## hbase
build_hbase:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/emr/hbase/hbase.Dockerfile ${IMAGE_HBASE} ./Dockerfiles/emr/hbase/

build_hbase_compile:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/emr/hbase/hbase_compile.Dockerfile ${IMAGE_HBASE} ./Dockerfiles/emr/hbase/

run_hbase:
	docker run -d -it --hostname test-hbase --name dev_hbase -p 16000:16000 -p 16010:16010 -p 16201:16201 -p 16301:16301 -p 9090:9090 ${IMAGE_HBASE}

## hudi
build_hudi:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/emr/hudi/hudi.Dockerfile ${IMAGE_HUDI} ./Dockerfiles/emr/hudi/

## hue
build_hue:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/emr/hue/hue.Dockerfile ${IMAGE_HUE} ./Dockerfiles/emr/hue/

run_hue:
	bash ${compose_script} run ./deployments/compose/hue/hue.yml

remove_hue:
	bash ${compose_script} remove ./deployments/compose/hue/hue.yml

run_hue_hive:
	bash ${compose_script} run ./deployments/compose/hue/hue_hive.yml

remove_hue_hive:
	bash ${compose_script} remove ./deployments/compose/hue/hue_hive.yml

run_hue_presto:
	bash ${compose_script} run ./deployments/compose/hue/hue_presto.yml

remove_hue_presto:
	bash ${compose_script} remove ./deployments/compose/hue/hue_presto.yml

## jupyter
build_jupyter:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/emr/jupyter/jupyter.Dockerfile ${IMAGE_JUPYTER} ./Dockerfiles/emr/jupyter/

run_jupyter:
	${CLI} run -it -d --hostname test_jupyter --name dev_jupyter -p 8000:8000 ${IMAGE_JUPYTER}

run_jupyter_lab:
	${CLI} run -it -d --hostname test_jupyter --name dev_jupyter -e component=lab -p 8000:8000 ${IMAGE_JUPYTER}

## zeppelin
build_zeppelin:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/emr/zeppelin/zeppelin.Dockerfile ${IMAGE_ZEPPELIN} ./Dockerfiles/emr/zeppelin/

run_zeppelin:
	docker run -d -it --hostname test-zeppelin --name dev_zeppelin -p 8080:8080 ${IMAGE_ZEPPELIN}

## presto
build_presto:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/emr/presto/presto.Dockerfile ${IMAGE_PRESTO} ./Dockerfiles/emr/presto/

build_presto_compile:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/emr/presto/presto_compile.Dockerfile ${IMAGE_PRESTO} ./Dockerfiles/emr/presto/

run_presto:
	docker run -d -it --hostname test_presto --name dev_presto -p 8080:8080 -e HIVE_METASTORE_URL=hive_metastore_host:hive_metastore_port -e HADOOP_CONF_DIR=/etc/hadoop/conf -v /etc/hadoop/conf:/etc/hadoop/conf ${PRESTO_IMAGE}

## trino
build_trino:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/emr/trino/trino.Dockerfile ${IMAGE_TRINO} ./Dockerfiles/emr/trino/

build_trino_compile:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/emr/trino/trino_compile.Dockerfile ${IMAGE_TRINO} ./Dockerfiles/emr/trino/

run_trino:
	docker run -d -it --hostname test_trino --name dev_trino -p 8080:8080 -e HIVE_METASTORE_URL=hive_metastore_host:hive_metastore_port -e HADOOP_CONF_DIR=/etc/hadoop/conf -v /etc/hadoop/conf:/etc/hadoop/conf ${IMAGE_TRINO}

## knox
build_knox:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/emr/knox/knox.Dockerfile ${IMAGE_KNOX} ./Dockerfiles/emr/knox/

build_knox_compile:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/emr/knox/knox_compile.Dockerfile ${IMAGE_KNOX} ./Dockerfiles/emr/knox/

run_knox:
	docker run -d -it --hostname test-knox --name dev_knox -p 8443:8443 ${IMAGE_KNOX}

## es
build_es:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/emr/elasticsearch/es.Dockerfile ${IMAGE_ES} ./Dockerfiles/emr/elasticsearch/

run_es:
	docker run -d -it --hostname test-es --name dev_es -p 9200:9200 ${IMAGE_ES}

run_es_kibana:
	bash ${compose_script} run ./deployments/compose/elasticsearch/es_kibana.yml

remove_es_kibana:
	bash ${compose_script} remove ./deployments/compose/elasticsearch/es_kibana.yml

## kibana
build_kibana:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/emr/elasticsearch/kibana.Dockerfile ${IMAGE_KIBANA} ./Dockerfiles/emr/elasticsearch/

run_kibana:
	docker run -d -it --hostname test-kibana --name dev_kibana -p 5601:5601 ${IMAGE_KIBANA}

## atlas
build_atlas:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/emr/atlas/atlas.Dockerfile ${IMAGE_ATLAS} ./Dockerfiles/emr/atlas/

run_atlas:
	docker run -d -it --hostname test-atlas --name dev_atlas -p 21000:21000 ${IMAGE_ATLAS}

## clickhouse
build_clickhouse:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/emr/clickhouse/clickhouse.Dockerfile ${IMAGE_CLICKHOUSE} ./Dockerfiles/emr/clickhouse/

run_clickhouse_singleton:
	bash ${compose_script} run ./deployments/compose/clickhouse/clickhouse_singleton.yml

remove_clickhouse_singleton:
	bash ${compose_script} remove ./deployments/compose/clickhouse/clickhouse_singleton.yml

run_clickhouse_cluster:
	bash ${compose_script} run ./deployments/compose/clickhouse/clickhouse_cluster.yml

remove_clickhouse_cluster:
	bash ${compose_script} remove ./deployments/compose/clickhouse/clickhouse_cluster.yml

## starrocks
build_starrocks:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/emr/starrocks/starrocks.Dockerfile ${IMAGE_STARROCKS} ./Dockerfiles/emr/starrocks/

run_starrocks_singleton:
	bash ${compose_script} run ./deployments/compose/starrocks/starrocks_singleton.yml

remove_starrocks_singleton:
	bash ${compose_script} remove ./deployments/compose/starrocks/starrocks_singleton.yml

run_starrocks_cluster:
	bash ${compose_script} run ./deployments/compose/starrocks/starrocks_cluster.yml

remove_starrocks_cluster:
	bash ${compose_script} remove ./deployments/compose/starrocks/starrocks_cluster.yml

## doris
build_doris:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/emr/doris/doris.Dockerfile ${IMAGE_DORIS} ./Dockerfiles/emr/doris/

run_doris_singleton:
	bash ${compose_script} run ./deployments/compose/doris/doris_singleton.yml

remove_doris_singleton:
	bash ${compose_script} remove ./deployments/compose/doris/doris_singleton.yml

run_doris_cluster:
	bash ${compose_script} run ./deployments/compose/doris/doris_cluster.yml

remove_doris_cluster:
	bash ${compose_script} remove ./deployments/compose/doris/doris_cluster.yml

## minio
build_minio:
	bash ${build_script} ${cmd} ${platform} ./Dockerfiles/emr/minio/minio.Dockerfile ${IMAGE_MINIO} ./Dockerfiles/emr/minio/

run_minio:
	docker run -d -it --hostname test_minio --name dev_minio ${IMAGE_MINIO}

# build net image
## xrdp
build_xrdp:
	bash ${build_script} ${cmd} linux/amd64 ./Dockerfiles/net/xrdp/xrdp.Dockerfile ${IMAGE_XRDP} ./Dockerfiles/net/xrdp/

run_xrdp:
	${CLI} run -it -d --privileged=true --platform linux/amd64 --hostname test_xrdp --name dev_xrdp -p 33389:3389 -p 37881:7881 ${IMAGE_XRDP} /usr/sbin/init

## easyconnect
build_ec:
	bash ${build_script} ${cmd} linux/amd64 ./Dockerfiles/net/ec/easyconnect.Dockerfile ${IMAGE_EC} ./Dockerfiles/net/ec/

run_ec:
	${CLI} run -it -d --privileged=true --platform linux/amd64 --hostname test_ec --name dev_ec -p 33389:3389 -p 37881:7881 ${IMAGE_EC} /usr/sbin/init