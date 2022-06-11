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
|   | python | make build_dev_python | python develop env<br>miniforge: 4.12.0<br>python: 3.8 |
|   | nodejs | make build_dev_nodejs | nodejs develop env<br>nodejs: v16.15.0 |
|   | full | make build_dev_full | include all develop env above |
| frontend  | vue admin | make build_vue_admin | vue-admin 4.4.0 |
|   | ant design | make build_ant_design | ant-design 5.2.0 |
| middleware  | mysql | make build_mysql | mysql 8.0.27 |
|   | redis | make build_redis | redis 7.0-rc2 |
|   | prometheus | make build_prometheus | prometheus 2.33.4<br>grafana 8.4.2<br>alertmanager 0.23.0 |
|   | zookeeper | make build_zookeeper | zookeeper 3.6.3 |
| emr  | airflow | make build_airflow | airflow 2.1.2 |
|   | hdfs | make build_hdfs | hdfs 3.3.2 |
|   | hive | make build_hive | hive 3.1.2 |
|   | hue | make build_hue | hue 4.3.0 fix branch: [dev_bugfix](https://github.com/smiecj/hue/tree/dev_bugfix) |
|   | jupyter | make build_jupyter | jupyterlab 3.3.3<br>notebook 6.4.10 |
| net  | xrdp | make build_xrdp | [xrdp](https://github.com/neutrinolabs/xrdp) |
|   | easyconnect | make build_ec | [easyconnect](https://www.sangfor.com/cybersecurity/products/easyconnect)<br>clash<br>firefox |

note: build image & run container defail command refer: [Makefile](https://github.com/smiecj/docker-centos/blob/main/Makefile)

### docker-compose

|  type   | service  | run command | feature
|  ----  | ---- | ---- | ---- |
|  middleware  | zookeeper | make run_zookeeper_cluster | zookeeper cluster(3 node)<br>connect on host: zkCli.sh -server localhost:12181<br>[refer](https://github.com/acntech/docker-zookeeper/blob/develop/docker-compose.cluster.yml) |
|    | kafka | make run_kafka_cluster | kafka cluster(3 node) |
|    | nacos | make run_nacos_mysql | nacos+mysql<br>address: http://localhost:8848 |
|    | prometheus | **todo** | prometheus+grafana+alertmanager<br>[refer](https://github.com/docker/awesome-compose/tree/master/prometheus-grafana) |
|  emr  | hadoop   | **todo** | hadoop cluster<br>[refer](https://zhuanlan.zhihu.com/p/421375012) |
|  web+backend  |  |  | |
