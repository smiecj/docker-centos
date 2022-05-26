# docker-centos
提供 Centos 开发和服务部署基础镜像

## 项目背景
[博客-通过 DockerFile 搭建开发镜像](https://smiecj.github.io/2021/12/19/dockerfile-centos-dev/)

目标: 重复工作的收敛
利用 Docker 制作可一键运行的镜像，直接运行环境，提升开发和学习效率

## 项目目录
- deployments
  - compose: 用于 docker-compose 的部署文件

- Dockerfiles
  - backend: 中间件服务 Dockerfile
  - dev: 开发用 Dockerfile，如 golang 环境基础镜像
  - emr: 大数据组件 Dockerfile
  - system: 系统 Dockerfile，如 centos_base

## 镜像整理和使用方式

### 基础镜像

|  类型   | 组件/镜像名  | 构建方式 | 功能
|  ----  | ---- | ---- | ---- |
| 基础  | base | # 完整基础镜像<br>make build_base | centos8, yum源, [s6](https://github.com/just-containers/s6-overlay), [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh), crontab  |
|   | minimal | # 最小基础镜像<br>make build_minimal<br># centos7 版本<br>make build_minimal_7  | centos, yum源, s6, crontab |
| 开发  | golang | make build_dev_golang | golang 开发环境<br>默认 goproxy: goproxy.cn |
|   | java | # 完整版, 包含java, maven, gradle<br>make build_dev_java<br># minimal, 只包含java<br>make build_dev_java_minimal  | java 开发环境<br>openjdk<br>JAVA_HOME: jdk8<br>JDK_HOME: jdk11, 用于 vscode 远程开发<br>maven: 3.8.4<br>gradle: 7.0.2 |
|   | python | make build_dev_python | python 开发镜像<br>miniforge: 4.12.0<br>python: 3.8 |
|   | nodejs | make build_dev_nodejs | nodejs 开发镜像<br>nodejs: v16.15.0 |
|   | full | make build_dev_full | 包含以上开发环境 |
| 中间件  | mysql | make build_mysql | mysql 8.0.27 |
|   | redis | make build_redis | redis 7.0-rc2 |
|   | prometheus | make build_prometheus | prometheus 2.33.4<br>grafana 8.4.2<br>alertmanager 0.23.0 |
|   | zookeeper | make build_zookeeper | zookeeper 3.6.3 |
| emr  | airflow | make build_airflow | airflow 2.1.2 |
|   | hdfs | make build_hdfs | hdfs 3.3.2 |
|   | hive | make build_hive | hive 3.1.2 |
|   | hue | make build_hue | hue 4.3.0 修复版[dev_bugfix](https://github.com/smiecj/hue/tree/dev_bugfix) |
|   | jupyter | make build_jupyter | jupyterlab 3.3.3<br>notebook 6.4.10 |

注: 具体构建镜像 & 启动容器的指令可参考 [Makefile](https://github.com/smiecj/docker-centos/blob/main/Makefile)

### docker-compose

|  类型   | 服务名  | 启动方式 | 功能
|  ----  | ---- | ---- | ---- |
|  中间件  | zookeeper | make run_zookeeper_cluster | zookeeper 三节点集群<br>开放地址: zkCli.sh -server localhost:12181<br>[参考资料](https://github.com/acntech/docker-zookeeper/blob/develop/docker-compose.cluster.yml) |
|    | nacos | make run_nacos_mysql | nacos+mysql<br>地址: http://localhost:8848 |
|    | prometheus | todo | prometheus+grafana<br>[参考资料](https://github.com/docker/awesome-compose/tree/master/prometheus-grafana) |
|  大数据  | hadoop   | todo | hadoop cluster<br>[参考资料](https://zhuanlan.zhihu.com/p/421375012) |
|  后台+前端  |  |  | |

## 待规划需求

|  开发周期   |  需求   | 功能  | 状态 |
|  ----  | ---- | ---- | ---- |
| 一期 |  规范 Dockerfile  | 安装脚本统一封装到 Dockerfile 中，通过 RUN 定义<br>体现层级结构，如: centos_hue -> centos_python -> centos_base | 已完成 |
| 一期 |  dockerfile 支持更多大数据组件  | 支持 vm, tidb, atlas, superset | 实现中 |
| 一期 |  compose 支持基本组件  | 支持 nacos、zk cluster | 实现中 |
| 一期 |  readme 完善  | 项目背景 & makefile & vscode remote 开发 & compose 使用 | 实现中 |
| 一期 |  makefile  | 所有镜像构建、启动服务指令都放在 makefile 中 | 实现中 |
| 一期 |  readme 完善  | 项目背景 & makefile & vscode remote 开发 & compose 使用 | 实现中 |
| 三期 |  通过 K8S 搭建zk 集群  | 声明 k8s 部署配置文件，一键启动 zk 集群 | |
| 持续迭代 |  需要扩展的 dockerfile  | backend - [gocron](https://github.com/ouqiang/gocron): 定时任务调度, 可结合 docker-compose 测试集群功能 | |
|  |  需要扩展的 dockerfile  | backend - [TiDB](https://github.com/pingcap/tidb) | |
|  |  需要扩展的 dockerfile  | emr - [atlas](https://github.com/apache/atlas) | |

## 最后，欢迎大家一起交流一起学习！
如果你对镜像或者这个仓库有任何疑问，都欢迎直接通过 issue 直接提问题和建议