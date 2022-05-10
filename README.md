# docker-centos
提供一个centos开发镜像

## 项目背景
[博客-通过 DockerFile 搭建开发镜像](https://smiecj.github.io/2021/12/19/dockerfile-centos-dev/)

利用容器化技术，提升开发和学习效率

## 项目目录
├── deployments
├──── 用于 k8s 的部署文件
├── Dockerfiles
│   ├── backend
│   ├──── 后台服务 Dockerfile
│   ├── dev
│   ├──── 开发用 Dockerfile，如 golang 环境基础镜像
│   ├── emr
│   ├──── 大数据组件 Dockerfile
│   └── system
│   └──── 系统 Dockerfile，如 centos_base

## 使用方式
### 构建系统镜像
```
# centos 最小基础镜像（用于部署服务）
docker build --no-cache -f centos_minimal.Dockerfile -t centos_minimal .

# centos 基础开发镜像（包含基本开发依赖，用于构建开发镜像）
docker build --no-cache -f centos_base.Dockerfile -t centos_base .
```

### 构建开发镜像
注意: 需要先构建好 centos_base 镜像

#### java
```
docker build --no-cache -f centos_dev_java.Dockerfile -t centos_java .
```

#### golang
```
docker build --no-cache -f centos_dev_golang.Dockerfile -t centos_golang .
```

#### nodejs
```
docker build --no-cache -f centos_dev_nodejs.Dockerfile -t centos_nodejs .
```

#### python
```
docker build --no-cache -f centos_dev_python.Dockerfile -t centos_python .
```

#### full
注意: 需要先构建好 以上四个镜像
```
docker build --no-cache -f centos_dev_full.Dockerfile -t centos_dev_full .
```

### 构建组件镜像
#### 后台 - mysql
```
docker build -f mysql.Dockerfile -t centos_mysql .

docker run -d -it centos_mysql
```

#### 后台 - nacos
```
docker build -f nacos.Dockerfile -t centos_nacos .

docker run -d -it -p 8848:8848 --env MYSQL_HOST=mysql_host --env MYSQL_PORT=mysql_port --env MYSQL_USER=mysql_user --env MYSQL_PASSWORD=mysql_password --env MYSQL_DB=mysql_db centos_nacos
```

#### 后台 - zookeeper
```
docker build --no-cache -f zookeeper.Dockerfile -t centos_zookeeper .

单机模式
docker run -d -it -p 2181:2181 centos_zookeeper

集群模式（完整配置参考后续提供的 docker-compose 部署方式）
docker run -it -d --env MODE=cluster --env MYID=1 --env SERVER_INFO=zk_host1:2888:3888,zk_host2:2888:3888,zk_host3:2888:3888 -p 2181:2181 centos_zookeeper
```

#### 后台 - redis
docker build -f redis.Dockerfile -t centos_redis .

docker run -d -it centos_redis

#### 后台 - prometheus (包含 alertmanager + grafana)
```
# 通过编译源码方式构建
docker build -f prometheus_compile.Dockerfile -t centos_prometheus

# 直接安装可执行包构建
docker build -f prometheus_pkg.Dockerfile -t centos_prometheus

# 运行
docker run -d -it -p 3000:3000 -p 3001:3001 centos_prometheus
```

#### 后台 - pip2pi
```
# 构建
docker build -f pip2pi.Dockerfile -t centos_pip2pi

# 运行
docker run -d -it -p 8000:80 centos_pip2pi
```

#### 大数据 - druid
```
# 构建编译基础镜像（需要包含 java, python 和 nodejs）
docker build --no-cache -f druid_base.Dockerfile -t centos_druid_base .

# 构建druid镜像
docker build -f druid.Dockerfile -t centos_druid .

# 运行
docker run -it -d -p 8888:8888 centos_druid
```

#### 大数据 - hudi
```
# 构建hudi镜像
docker build -f hudi.Dockerfile -t centos_hudi .

# 运行
docker run -it -d -p 8888:8888 centos_hudi
```

#### 大数据 - airflow
```
# 构建airflow镜像
docker build -f airflow.Dockerfile -t centos_airflow .

# 运行
docker run -it -d -p 8072:8072 centos_airflow
```

### docker-compose 实践
#### zookeeper cluster
```
# todo
```

#### nacos+mysql
```
# todo
```

### 备注: docker run: --privileged 和 /usr/sbin/init 是必选项，因为系统需要初始化 root 账户相关服务和权限
docker run -d --privileged=true -p 2222:22 centos_dev /usr/sbin/init

然后 本地就可以直接连接到centos 镜像了:
ssh root@root!centos123 -p 2222

## 项目目录
scripts: 放到开发镜像中的脚本

Dockerfiles: 存放各个开发用到的 DockerFile

## 待规划需求
### 需要创建的 dockerfile
- 定时任务调度, 可结合 docker-compose 测试集群功能
https://github.com/ouqiang/gocron

### 规范 Dockerfile
减少脚本的使用，大部分组件安装的逻辑放到 Dockerfile 中

体现层级结构，比如 centos_hue -> centos_python -> centos_base

实现顺序
- dev 镜像

- 后台中间件
nacos、zookeeper、redis、mysql 等

- 大数据组件
hive、hue 等

### 支持 docker-compose
完全通过 配置文件 声明的方式，构建镜像

### 基础环境（java、python 等）通过 脚本安装
主要考虑目前代码中，安装基础环境已经有很多重复代码，封装到脚本中比较方便维护

### docker build makefile
参考: kubeflow

### centos_dev DockerFile 支持自定义需要安装的环境/组件
可以在 docker run 中输入组件名，自动安装对应组件
如: docker run --env "INSTALL_PLUGINS=zookeeper,mysql"

### zookeeper 集群的本地部署
通过 K8S 搭建zk 集群

### 各组件搭建的版本配置化
这里的配置化指的是在构建镜像 (docker build) 的时候可指定，升级版本不需要修改脚本代码

## 最后，欢迎大家一起交流一起学习！
如果你对镜像或者这个仓库有任何疑问，都欢迎直接通过 issue 直接提问题和建议