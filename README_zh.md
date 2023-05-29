# docker-centos
提供 Centos 开发和服务部署基础镜像

## 项目背景
[博客-通过 DockerFile 搭建开发镜像](https://smiecj.github.io/2021/12/19/dockerfile-centos-dev/)

目标: **重复工作的收敛**
利用 Docker 制作可一键运行的镜像，直接运行环境，提升开发和学习效率

项目扩展:
[通过 Docker Compose 本地启动 hadoop 集群](https://smiecj.github.io/2022/08/13/dockerfile-compose-hdfs)

[通过 Docker Compose 本地启动 zk 集群](https://smiecj.github.io/2022/05/18/dockerfile-compose/)

## 项目目录
- deployments
  - compose: 用于 docker-compose 的部署文件

- Dockerfiles
  - system: 系统基础镜像，如 centos_base
  - dev: 开发用基础镜像，如: golang 环境基础镜像
  - frontend: 前端服务
  - backend: 后台/中间件服务
  - emr: 大数据组件
  - net: 用于调试网络的基础镜像

- Makefile
  - Makefile.vars.repo: 各软件源地址
  - Makefile.vars: 服务版本
  - Makefile: 一键运行 镜像构建、提交、运行服务等指令

## 镜像整理和使用方式

### 基础镜像

|  类型   | 组件/镜像名  | 构建方式 | 功能
|  ----  | ---- | ---- | ---- |
| 基础  | base | # 完整基础镜像<br>make build_base | centos8, yum源, [s6](https://github.com/just-containers/s6-overlay), [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh), crontab  |
|   | minimal | # 最小基础镜像<br>make build_minimal<br># centos7 版本<br>make build_minimal_7  | centos, yum源, s6, crontab |
| 开发  | golang | make build_dev_golang | golang 1.19 |
|   | java | # 完整版, 包含java, maven, gradle<br>make build_dev_java<br># minimal, 只包含java<br>make build_dev_java_minimal  | java 开发环境<br>openjdk<br>JAVA_HOME: jdk8<br>JDK_HOME: jdk11, 用于 vscode 远程开发<br>maven: 3.8.4<br>gradle: 7.0.2 |
|   | python | make build_dev_python | python 开发镜像<br>[miniforge](https://github.com/conda-forge/miniforge): 4.13.0<br>python: 3.8.13 |
|   | nodejs | make build_dev_nodejs | nodejs 开发镜像<br>nodejs: v16.15.0 |
|   | full | make build_dev_full | 包含以上开发环境 |
| 前端  | vue admin | make build_vue_admin | vue-admin 4.4.0 |
|   | [ant design](https://pro.ant.design) | make build_ant_design | ant-design 5.2.0 |
| 中间件  | [mysql](https://www.mysql.com) | make build_mysql | mysql 8.0.27 |
|   | [postgresql](https://www.postgresql.org) | make build_pgsql | postgresql 14 |
|   | [redis](https://redis.io) | make build_redis | redis 7.0-rc2 |
|   | [mongodb](https://www.mongodb.com) | make build_mongo | mongo 6.0.0 |
|   | [prometheus](https://prometheus.io) | make build_prometheus | prometheus 2.33.4<br>alertmanager 0.23.0<br>pushgateway 1.4.3<br>node exporter 1.3.1 |
|   | [grafana](https://grafana.com) | make build_grafana | grafana 8.4.2 |
|   | [zookeeper](https://zookeeper.apache.org) | make build_zookeeper | zookeeper 3.6.3 |
|   | [kafka](https://kafka.apache.org) | make build_kafka | kafka 3.2 |
|   | [nginx](https://www.nginx.com) | make build_nginx | nginx 1.23.2 |
| emr  | [airflow](https://airflow.apache.org) | make build_airflow | airflow 2.1.2 |
|   | [hdfs](https://hadoop.apache.org) | make build_hdfs | hdfs 3.3.2 |
|   | [hive](https://hive.apache.org) | make build_hive | hive 3.1.2 |
|   | [knox](https://knox.apache.org) | make build_knox | knox 1.6.1 |
|   | hdfs_full | make build_hdfs | hdfs 3.3.2<br>knox 1.6.1<br>hive 3.1.2<br>spark 3.2<br>flink 1.15 |
|   | [hue](https://gethue.com) | make build_hue | hue 4.3.0 修复版[dev_bugfix](https://github.com/smiecj/hue/tree/dev_bugfix) |
|   | [jupyter](https://jupyter.org) | make build_jupyter | jupyterlab 3.3.3<br>notebook 6.4.10 |
|   | [zeppelin](https://zeppelin.apache.org) | make build_zeppelin | zeppelin 0.10.1 |
|   | [presto](https://prestodb.io) | make build_presto | presto 0.275 |
|   | [trino](https://trino.io) | make build_trino | trino 403 |
|   | [superset](https://superset.apache.org) | make build_superset | superset 2.0.0 |
|   | [azkaban](https://azkaban.github.io) | make build_azkaban | azkaban master branch |
|   | [prefect](https://www.prefect.io) | make build_prefect | prefect 2.7.7 |
|   | [dolphinscheduler](https://github.com/apache/dolphinscheduler) | make build_dolphinscheduler | dolphinscheduler 3.1.4 |
|   | [flink](https://github.com/apache/flink) | make build_flink | flink 1.15 |
|   | [datalink](https://github.com/ucarGroup/DataLink) | make build_datalink | [datalink dev branch](https://github.com/smiecj/datalink/tree/dev_bugfix) |
|   | [elasticsearch](https://www.elastic.co/cn/elasticsearch) | make build_es | elasticsearch 8.4.1 |
|   | [kibana](https://www.elastic.co/cn/kibana) | make build_kibana | kibana 8.4.1 |
|   | [atlas](https://atlas.apache.org) | make build_atlas | atlas 2.2.0 |
|   | [clickhouse](https://github.com/ClickHouse/ClickHouse) | make build_clickhouse | clickhouse 21.7.8 |
|   | [starrocks](https://starrocks.io) | make build_starrocks | starrocks 2.5.3 |
|   | [minio](https://github.com/minio/minio) | make build_minio | minio release |
| net  | [xrdp](https://github.com/neutrinolabs/xrdp) | make build_xrdp | centos with xrdp |
|   | [easyconnect](https://www.sangfor.com/cybersecurity/products/easyconnect) | make build_ec | easyconnect 7.6.7.3<br>[clash](https://github.com/Dreamacro/clash) 1.10.6<br>firefox |

注: 具体构建镜像 & 启动容器的指令可参考 [Makefile](https://github.com/smiecj/docker-centos/blob/main/Makefile)

### dockerhub

你也可以采用从 dockerhub 直接下载镜像的方式，不需要在本地构建镜像。只要在大部分 make 指令前面加上 REPO 参数即可，示例:

```shell
# dev_full
REPO=mzsmieli make run_dev_full
# 将下载: mzsmieli/centos:base8_dev_full_1.0

# jupyter
REPO=mzsmieli make run_jupyter
# 将下载: mzsmieli/centos:base8_jupyter3.3

# nacos
REPO=mzsmieli make run_nacos_mysql
# 将下载: mzsmieli/centos:minimal8_mysql8 and mzsmieli/centos:base8_nacos2.1.2
```

### 服务

|  类型   | 服务名  | 启动方式 | 功能
|  ----  | ---- | ---- | ---- |
|  开发工具  | code server   | REPO=mzsmieli make run_code_server | code server: http://localhost:8080 |
|    | oauth server   | REPO=mzsmieli SERVER_HOST=server_host make run_oauth_server  | oauth client: http://${server_host}:19094 |
|  中间件  | zookeeper | REPO=mzsmieli make run_zookeeper_cluster | zookeeper 三节点集群<br>开放地址: zkCli.sh -server localhost:12181<br>[参考资料](https://github.com/acntech/docker-zookeeper/blob/develop/docker-compose.cluster.yml) |
|    | kafka | REPO=mzsmieli make run_kafka_cluster | kafka 三节点集群（zk 单点） |
|    | nacos | REPO=mzsmieli make run_nacos_mysql | nacos+mysql<br>地址: http://localhost:8848 |
|    | prometheus+grafana | REPO=mzsmieli make run_prometheus_grafana | grafana: http://localhost:3000<br>prometheus: http://localhost:3001 |
|    | kafka+efak | REPO=mzsmieli make run_kafka_efak | efak: http://localhost:38042<br>admin/123456 |
|  大数据  | hadoop   | REPO=mzsmieli make run_hdfs_cluster | hadoop cluster<br>hdfs: http://localhost:8443/gateway/sandbox/hdfs<br>yarn: http://localhost:8443/gateway/sandbox/yarn<br>hive: localhost:10000<br>mysql: localhost:33306 |
|    | hue   | REPO=mzsmieli make run_hue | hue: http://localhost:8281<br>admin/admin |
|    | azkaban   | REPO=mzsmieli make run_azkaban | azkaban web: http://localhost:8020 |
|    | datalink   | REPO=mzsmieli make run_datalink_singleton | datalink: http://localhost:18080<br>admin/admin |
|    | clickhouse   | REPO=mzsmieli make run_clickhouse_cluster | clickhouse 3节点集群: localhost:18123,localhost:28123,localhost:38123 |
|    | starrocks   | REPO=mzsmieli make run_starrocks_cluster | starrocks 3节点集群，主节点: localhost:19030 |
|    | es+kibana   | REPO=mzsmieli make run_es_kibana | es: http://localhost:9200<br>kibana: http://localhost:5601 |
|    | flink  | REPO=mzsmieli make run_flink | flink ui: http://localhost:8081 |

## 待规划需求

|  开发周期   |  需求   | 功能  | 状态 |
|  ----  | ---- | ---- | ---- |
| 一期 |  规范 Dockerfile  | 安装脚本统一封装到 Dockerfile 中，通过 RUN 定义<br>体现层级结构，如: centos_hue -> centos_python -> centos_base | 完成 |
| 一期 |  compose 支持基本组件  | 支持 nacos、zk cluster | 完成 |
| 一期 |  readme 完善  | 项目背景 & makefile & vscode remote 开发 & compose 使用 | 完成 |
| 一期 |  makefile  | 所有镜像构建、启动服务指令都放在 makefile 中 | 完成 |
| 二期 |  compose  | 支持 hdfs cluster 本地搭建 | 完成 |
| 二期 |  jupyter  | lab2、lab3 均安装常用插件，提升体验 | 完成 |
| 二期 |  dockerfile  | 优化 镜像 tag，如 java 镜像 tag 跟随 jdk 版本，java:v1_8 | 完成 |
| 二期 |  dockerfile  | dev 相关基础环境下载源可通过 ARG 配置 | 完成 |
| 二期 |  dockerfile  | 相关组件的版本放到 Makefile.vars 中，如 maven 版本 | 完成 |
| 二期 |  readme  | 每个镜像（dockerfile）都提供单独的 readme，说明如何启动容器和服务提供的端口、服务页面截图，方便用户了解如何使用 | 待规划 |
| 三期 |  通过 K8S 搭建 zk 集群  | 声明 k8s 部署配置文件，一键启动 zk 集群 | 待实现 |
| 三期 |  vscode 开发镜像  | 预装开发环境，包括语言环境、vscode server 等 | 待实现 |
| 三期 |  镜像优化  | 通过环境变量 net_cn 区分不同的网络环境 | 待实现 |
| 四期 |  组件优化 | 存储组件的高可用探索，如: es、clickhouse 集群 | |
| 四期 |  组件优化 | 调度组件的高可用探索，如: azkaban、airflow | |
| 四期 |  组件优化 | emr组件的高可用探索，如: hdfs 集群和 namenode 高可用 | |
| 四期 |  组件优化 | 各个组件的 https / ssl 启动、连接方式探索 | |
| 四期 |  组件优化 | 各个组件对接统一的代理服务（nginx / knox）探索 | |
| 四期 |  组件优化 | 各个组件的可视化管理平台，类似 ambari | |
| 四期 |  镜像优化 | 区分组件的编译镜像和运行镜像，运行镜像使用更轻量的 | |
| 持续迭代 |  需要扩展的 dockerfile  | backend - [TiDB](https://github.com/pingcap/tidb) | |
|  |  需要扩展的 dockerfile  | emr - [nebula](https://github.com/vesoft-inc/nebula) | |
|  |  需要扩展的 dockerfile  | emr - [datahub](https://github.com/datahub-project/datahub) | |
|  |  需要扩展的 dockerfile  | dev - 开发镜像扩展 vscode 插件 | |
|  |  需要扩展的 compose  | emr - clickhouse 三节点集群(待验证) | |
|  |  需要扩展的 compose  | emr - flink 集群 (带 master) | |
|  |  需要扩展的功能  | base - 新增工具脚本，连接 mysql 验证，将 azkaban 等组件的逻辑统一 | |
|  |  需要扩展的功能  | 存储相关镜像新增测试脚本，进行基本的 CURD 操作并返回结果 | |

## 最后，欢迎大家一起交流一起学习！
如果你对镜像或者这个仓库有任何疑问，都欢迎直接通过 issue 直接提问题和建议
