# docker-centos
Centos image stacks for develop and deploy components

[中文版 Readme](https://github.com/smiecj/docker-centos/blob/main/README_zh.md)

## background
[blog-Use Dockerfile to build develop image](https://smiecj.github.io/2021/12/19/dockerfile-centos-dev/)

Target: save my day
Use dockerfile and compose file to build docker image and run develop environment.

extend blog:
[Use Docker Compose to start hdfs cluster locally](https://smiecj.github.io/2022/08/13/dockerfile-compose-hdfs)

[Use Docker Compose to start zookeeper cluster locally](https://smiecj.github.io/2022/05/18/dockerfile-compose/)

## project structure
- deployments
  - compose: deployment on docker compose

- Dockerfiles
  - system: centos basic image
  - dev: development env such as golang, java, python, nodejs
  - frontend: frontend service such as: vue admin, ant design
  - backend: backend service such as: zk, mysql, redis
  - emr: bigdata component, such as jupyter, hue
  - net: for network debug

- Makefile
  - Makefile.vars.repo: software repo
  - Makefile.vars: service version
  - Makefile: image build, push and service deploy single cmd

## All Image And How To Use

### basic image

|  type   | component/image name  | build command | feature
|  ----  | ---- | ---- | ---- |
| basic  | base | # full centos base image<br>make build_base | centos8, yum repo([tsinghua](https://mirrors.tuna.tsinghua.edu.cn/centos-vault/)), [s6](https://github.com/just-containers/s6-overlay), [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh), crontab  |
|   | minimal | # minimal centos base image<br>make build_minimal<br># build centos7 version<br>make build_minimal_7  | centos, yum repo(tsinghua), s6, crontab |
| develop  | golang | make build_dev_golang | golang 1.19 |
|   | java | # full, include java, maven, gradle<br>make build_dev_java<br># minimal, only include java<br>make build_dev_java_minimal | java develop env<br>openjdk<br>JAVA_HOME: jdk8<br>JDK_HOME: jdk11 for vscode java extension<br>maven: 3.8.4<br>gradle: 7.0.2 |
|   | python | make build_dev_python | python develop env<br>[miniforge](https://github.com/conda-forge/miniforge): 4.13.0<br>python: 3.8 |
|   | nodejs | make build_dev_nodejs | nodejs develop env<br>nodejs: v16.15.0 |
|   | full | make build_dev_full | include all develop env above |
| frontend  | vue admin | make build_vue_admin | vue-admin 4.4.0 |
|   | [ant design](https://pro.ant.design) | make build_ant_design | ant-design 5.2.0 |
| middleware  | [mysql](https://www.mysql.com) | make build_mysql | mysql 8.0.27 |
|   | [postgresql](https://www.postgresql.org) | make build_pgsql | postgresql 14 |
|   | [redis](https://redis.io) | make build_redis | redis 7.0-rc2 |
|   | [mongodb](https://www.mongodb.com) | make build_mongo | mongo 6.0.0 |
|   | [prometheus](https://prometheus.io) | make build_prometheus | prometheus 2.33.4<br>alertmanager 0.23.0<br>pushgateway 1.4.3<br>node exporter 1.3.1 |
|   | [grafana](https://grafana.com) | make build_grafana | grafana 8.4.2 |
|   | [zookeeper](https://zookeeper.apache.org) | make build_zookeeper | zookeeper 3.9.1 |
|   | [kafka](https://kafka.apache.org) | make build_kafka | kafka 3.2 |
|   | [nginx](https://www.nginx.com) | make build_nginx | nginx 1.23.2 |
| emr  | [airflow](https://airflow.apache.org) | make build_airflow | airflow 2.7.3 |
|   | [hdfs](https://hadoop.apache.org) | make build_hdfs | hdfs 3.3.2 |
|   | [hive](https://hive.apache.org) | make build_hive | hive 3.1.2 |
|   | [knox](https://knox.apache.org) | make build_knox | knox 1.6.1 |
|   | hdfs_full | make build_hdfs | hdfs 3.3.2<br>knox 1.6.1<br>hive 3.1.2<br>spark 3.2<br>flink 1.15 |
|   | [hue](https://gethue.com) | make build_hue | hue 4.3.0 fix branch: [dev_bugfix](https://github.com/smiecj/hue/tree/dev_bugfix) |
|   | [jupyter](https://jupyter.org) | make build_jupyter | jupyterlab 3.3.3<br>notebook 6.4.10 |
|   | [zeppelin](https://zeppelin.apache.org) | make build_zeppelin | zeppelin 0.10.1 |
|   | [presto](https://prestodb.io) | make build_presto | presto 0.275 |
|   | [trino](https://trino.io) | make build_trino | trino 403 |
|   | [flink](https://flink.apache.org) | make build_flink | flink 1.15 |
|   | [spark](https://spark.apache.org) | make build_spark | spark 3.4.1 |
|   | [superset](https://superset.apache.org) | make build_superset | superset 2.0.0 |
|   | [azkaban](https://azkaban.github.io) | make build_azkaban | azkaban master branch |
|   | [prefect](https://www.prefect.io) | make build_prefect | prefect 2.7.7 |
|   | [dolphinscheduler](https://github.com/apache/dolphinscheduler) | make build_dolphinscheduler | dolphinscheduler 3.1.4 |
|   | [datalink](https://github.com/ucarGroup/DataLink) | make build_datalink | [datalink dev branch](https://github.com/smiecj/datalink/tree/dev_bugfix) |
|   | [elasticsearch](https://www.elastic.co/cn/elasticsearch) | make build_es | elasticsearch 8.4.1 |
|   | [kibana](https://www.elastic.co/cn/kibana) | make build_kibana | kibana 8.4.1 |
|   | [atlas](https://atlas.apache.org) | make build_atlas | atlas 2.2.0 |
|   | [clickhouse](https://github.com/ClickHouse/ClickHouse) | make build_clickhouse | clickhouse 21.7.8 |
|   | [doris](https://doris.apache.org) | make build_doris | doris 2.0.2 |
|   | [starrocks](https://starrocks.io) | make build_starrocks | starrocks 2.5.3 |
|   | [minio](https://github.com/minio/minio) | make build_minio | minio release |
| net  | [xrdp](https://github.com/neutrinolabs/xrdp) | make build_xrdp | centos with xrdp |
|   | [easyconnect](https://www.sangfor.com/cybersecurity/products/easyconnect) | make build_ec | easyconnect 7.6.7.3<br>[clash](https://github.com/Dreamacro/clash) 1.10.6<br>firefox |
| entertainment | [navidrome](https://www.navidrome.org) | make build_navidrome | navidrome |

note: build image & run container defail command refer: [Makefile](https://github.com/smiecj/docker-centos/blob/main/Makefile)

### dockerhub

you can also pull these image from dockerhub, no need to build locally, just execute command in Makefile with REPO var. e.g.

```shell
# dev_full
REPO=mzsmieli make run_dev_full
# will pull mzsmieli/centos:base8_dev_full_1.0

# jupyter
REPO=mzsmieli make run_jupyter
# will pull mzsmieli/centos:base8_jupyter3.3

# nacos
REPO=mzsmieli make run_nacos_mysql
# will pull mzsmieli/centos:minimal8_mysql8 and mzsmieli/centos:base8_nacos2.1.2
```

### services

|  type   | service  | run command | feature
|  ----  | ---- | ---- | ---- |
|  dev tools  | code server   | REPO=mzsmieli make run_code_server | code server: http://localhost:8080 |
|    | oauth server   | REPO=mzsmieli SERVER_HOST=server_host make run_oauth_server  | oauth client: http://${server_host}:19094 |
|  middleware  | zookeeper | REPO=mzsmieli make run_zookeeper_cluster | zookeeper cluster(3 node)<br>connect on host: zkCli.sh -server localhost:12181<br>[refer](https://github.com/acntech/docker-zookeeper/blob/develop/docker-compose.cluster.yml) |
|    | kafka | REPO=mzsmieli make run_kafka_cluster | kafka cluster(3 node) |
|    | nacos | REPO=mzsmieli make run_nacos_mysql | nacos+mysql<br>address: http://localhost:8848 |
|    | prometheus+grafana | REPO=mzsmieli make run_prometheus_grafana | grafana: http://localhost:3000<br>prometheus: http://localhost:3001 |
|    | kafka+efak | REPO=mzsmieli make run_kafka_efak | efak: http://localhost:38042<br>admin/123456 |
|  emr  | hadoop   | REPO=mzsmieli make run_hdfs_cluster | hadoop cluster<br>hdfs: http://localhost:8443/gateway/sandbox/hdfs<br>yarn: http://localhost:8443/gateway/sandbox/yarn<br>hive: localhost:10000<br>mysql: localhost:33306 |
|    | hue   | REPO=mzsmieli make run_hue | hue: http://localhost:8281 |
|    | hue+hdfs+hive   | REPO=mzsmieli make run_hue_hive | hue: http://localhost:8281 |
|    | hue+hdfs+hive+presto   | REPO=mzsmieli make run_hue_presto | hue: http://localhost:8281 |
|    | azkaban   | REPO=mzsmieli make run_azkaban | azkaban web: http://localhost:8020 |
|    | datalink   | REPO=mzsmieli make run_datalink_singleton | datalink: http://localhost:18080<br>admin/admin |
|    | clickhouse   | REPO=mzsmieli make run_clickhouse_cluster | 3 clickhouse nodes: localhost:18123,localhost:28123,localhost:38123 |
|    | starrocks   | REPO=mzsmieli make run_starrocks_cluster | 3 starrocks nodes, master fe: localhost:19030 |
|    | doris   | REPO=mzsmieli make run_doris_cluster | 3 doris nodes，master fe: localhost:19030 |
|    | es+kibana   | REPO=mzsmieli make run_es_kibana | es: http://localhost:9200<br>kibana: http://localhost:5601 |
|    | flink  | REPO=mzsmieli make run_flink | flink ui: http://localhost:8081 |