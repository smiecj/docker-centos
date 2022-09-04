# docker-centos
Centos image stacks for develop and deploy components

[中文版 Readme](https://github.com/smiecj/docker-centos/blob/main/README_zh.md)

## background
[blog-Use Dockerfile to build develop image](https://smiecj.github.io/2021/12/19/dockerfile-centos-dev/)

Use dockerfile and compose file to build docker image and run develop environment. Make life more easy!

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

## All Image And How To Use

### basic image

|  type   | component/image name  | build command | feature
|  ----  | ---- | ---- | ---- |
| basic  | base | # full centos base image<br>make build_base | centos8, yum repo([tsinghua](https://mirrors.tuna.tsinghua.edu.cn/centos-vault/)), [s6](https://github.com/just-containers/s6-overlay), [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh), crontab  |
|   | minimal | # minimal centos base image<br>make build_minimal<br># build centos7 version<br>make build_minimal_7  | centos, yum repo(tsinghua), s6, crontab |
| develop  | golang | make build_dev_golang | golang develop env<br>default goproxy: goproxy.cn |
|   | java | # full, include java, maven, gradle<br>make build_dev_java<br># minimal, only include java<br>make build_dev_java_minimal | java develop env<br>openjdk<br>JAVA_HOME: jdk8<br>JDK_HOME: jdk11 for vscode java extension<br>maven: 3.8.4<br>gradle: 7.0.2 |
|   | python | make build_dev_python | python develop env<br>[miniforge](https://github.com/conda-forge/miniforge): 4.12.0<br>python: 3.8 |
|   | nodejs | make build_dev_nodejs | nodejs develop env<br>nodejs: v16.15.0 |
|   | full | make build_dev_full | include all develop env above |
| frontend  | vue admin | make build_vue_admin | vue-admin 4.4.0 |
|   | [ant design](https://pro.ant.design) | make build_ant_design | ant-design 5.2.0 |
| middleware  | mysql | make build_mysql | mysql 8.0.27 |
|   | [redis](https://redis.io) | make build_redis | redis 7.0-rc2 |
|   | [mongodb](https://www.mongodb.com) | make build_mongo | mongo 6.0.0 |
|   | [prometheus](https://prometheus.io) | make build_prometheus | prometheus 2.33.4<br>[grafana](https://grafana.com) 8.4.2<br>alertmanager 0.23.0 |
|   | [zookeeper](https://zookeeper.apache.org) | make build_zookeeper | zookeeper 3.6.3 |
| emr  | [airflow](https://airflow.apache.org) | make build_airflow | airflow 2.1.2 |
|   | [hdfs](https://hadoop.apache.org) | make build_hdfs | hdfs 3.3.2 |
|   | [hive](https://hive.apache.org) | make build_hive | hive 3.1.2 |
|   | [knox](https://knox.apache.org) | make build_knox | knox 1.6.1 |
|   | hdfs_full | make build_hdfs | hdfs 3.3.2<br>knox 1.6.1<br>hive 3.1.2<br>spark 3.2<br>flink 1.15 |
|   | [hue](https://gethue.com) | make build_hue | hue 4.3.0 fix branch: [dev_bugfix](https://github.com/smiecj/hue/tree/dev_bugfix) |
|   | [jupyter](https://jupyter.org) | make build_jupyter | jupyterlab 3.3.3<br>notebook 6.4.10 |
|   | [presto](https://prestodb.io) | make build_presto | presto 0.273.3 |
|   | [superset](https://superset.apache.org) | make build_superset | superset 1.4.2 |
| net  | [xrdp](https://github.com/neutrinolabs/xrdp) | make build_xrdp | centos with xrdp |
|   | [easyconnect](https://www.sangfor.com/cybersecurity/products/easyconnect) | make build_ec | easyconnect 7.6.7.3<br>[clash](https://github.com/Dreamacro/clash) 1.10.6<br>firefox |

note: build image & run container defail command refer: [Makefile](https://github.com/smiecj/docker-centos/blob/main/Makefile)

### dockerhub

you can also these image from dockerhub, no need to build locally, just execute command in Makefile with REPO var. e.g.

```shell
# base
docker pull mzsmieli/centos_base:v1.0.0

# dev_full
REPO=mzsmieli make run_dev_full
# will pull mzsmieli/centos_dev_full:v1.0.0

# jupyter
REPO=mzsmieli make run_jupyter
# will pull mzsmieli/centos_jupyter:v1.0.0

# nacos
REPO=mzsmieli make run_nacos_mysql
# will pull mzsmieli/centos_mysql:v1.0.0 and mzsmieli/centos_nacos:v1.0.0
```

### services

|  type   | service  | run command | feature
|  ----  | ---- | ---- | ---- |
|  middleware  | zookeeper | REPO=mzsmieli make run_zookeeper_cluster | zookeeper cluster(3 node)<br>connect on host: zkCli.sh -server localhost:12181<br>[refer](https://github.com/acntech/docker-zookeeper/blob/develop/docker-compose.cluster.yml) |
|    | kafka | REPO=mzsmieli make run_kafka_cluster | kafka cluster(3 node) |
|    | nacos | REPO=mzsmieli make run_nacos_mysql | nacos+mysql<br>address: http://localhost:8848 |
|    | prometheus | REPO=mzsmieli make run_prometheus | prometheus+grafana+alertmanager<br>grafana: http://localhost:3000<br>prometheus: http://localhost:3001 |
|  emr  | hadoop   | REPO=mzsmieli make run_hdfs_cluster | hadoop cluster<br>hdfs: http://localhost:8443/gateway/sandbox/hdfs<br>yarn: http://localhost:8443/gateway/sandbox/yarn<br>hive: localhost:10000<br>mysql: localhost:33306 |
|    | hue   | REPO=mzsmieli make run_hue | hue: http://localhost:8281 |
|    | azkaban   | REPO=mzsmieli make run_azkaban | azkaban web: http://localhost:8020 |
|  web+backend  | |  | |
