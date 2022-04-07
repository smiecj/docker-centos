# docker-centos
提供一个centos开发镜像

## 使用方式
### 构建开发镜像
docker build -f docker-centos/Dockerfiles/centos_dev -t centos_dev .

docker run -d --privileged=true -p 2222:22 centos_dev /usr/sbin/init

### 构建存储镜像 (目前只包括 mysql)
docker build -f docker-centos/Dockerfiles/centos_storage -t centos_storage .

docker run -d --privileged=true -p 3306:3306 centos_storage /usr/sbin/init

### 构建 redis 镜像
docker build -f docker-centos/Dockerfiles/centos_redis -t centos_redis .

docker run -d --privileged=true -p 6379:6379 centos_redis /usr/sbin/init

### 构建 jupyter notebook 镜像
docker build -f docker-centos/Dockerfiles/centos_jupyter -t centos_jupyter .

docker run -d --privileged=true -p 8000:8000 centos_jupyter /usr/sbin/init

### 构建 jupyter lab 镜像
docker build -f docker-centos/Dockerfiles/centos_jupyterlab -t centos_jupyterlab .

docker run -d --privileged=true -p 8000:8000 centos_jupyterlab /usr/sbin/init

### 构建 airflow 镜像
docker build -f docker-centos/Dockerfiles/centos_airflow -t centos_airflow .

docker run -d --privileged=true -p 8072:8072 centos_airflow /usr/sbin/init

### 构建 prometheus + grafana 镜像
docker build -f docker-centos/Dockerfiles/centos_prometheus -t centos_prometheus .

docker run -d --privileged=true -p 3000:3000 -p 3001:3001 centos_prometheus /usr/sbin/init

### 构建 hue 镜像
docker build -f Dockerfiles/centos_hue --build-arg MYSQL_HOST=mysql_host --build-arg MYSQL_PORT=mysql_port --build-arg MYSQL_USER=mysql_user --build-arg MYSQL_PASSWORD=mysql_password --build-arg MYSQL_DB=mysql_db -t centos_dev_hue .

docker run -d --privileged=true -p 38281:8281 centos_dev_hue /usr/sbin/init

### 构建 hdfs 镜像
docker build -f docker-centos/Dockerfiles/centos_hdfs -t centos_hdfs .

docker run -d --privileged=true -p 8088:8088 -p 50070:50070 centos_hdfs /usr/sbin/init

### 构建 hive 镜像
docker build -f docker-centos/Dockerfiles/centos_hive --build-arg MYSQL_HOST=mysql_host --build-arg MYSQL_PORT=mysql_port --build-arg MYSQL_USER=mysql_user --build-arg MYSQL_PASSWORD=mysql_password --build-arg MYSQL_DB=mysql_db --build-arg MYSQL_VERSION=8.0.26 -t centos_hive .

docker run -d --privileged=true -p 8088:8088 -p 50070:50070 -p 10000:10000 centos_hive /usr/sbin/init

### 构建 hudi 镜像
docker build -f docker-centos/Dockerfiles/centos_hudi -t centos_hive .

docker run -d --privileged=true -p 8088:8088 -p 50070:50070 -p 10000:10000 centos_hive /usr/sbin/init

### 构建 wordpress 镜像
docker build --build-arg MYSQL_ADDR=mysql_addr --build-arg MYSQL_USER=mysql_user --build-arg MYSQL_PASSWORD=mysql_password --no-cache -f Dockerfiles/centos_wordpress -t centos_wordpress .

docker run -d --privileged=true -p 8000:80 centos_wordpress /usr/sbin/init

### 构建 pip2pi 服务器
docker build -f docker-centos/Dockerfiles/centos_pip2pi -t centos_pip .

docker run -d --privileged=true -p 80:80 centos_pip /usr/sbin/init

### 备注: docker build: 可通过 ADMIN_PWD=pwd 设定 root 用户登录密码
示例: docker build --build-arg ROOT_PWD=root_Test123 --no-cache -f Dockerfiles/centos_dev -t centos_dev .

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

### 支持 docker-compose
完全通过 配置文件 声明的方式，构建镜像

### centos_dev DockerFile 支持自定义需要安装的环境/组件
可以在 docker run 中输入组件名，自动安装对应组件
如: docker run --env "INSTALL_PLUGINS=zookeeper,mysql"

### zookeeper 集群的本地部署
通过 K8S 搭建zk 集群

### 各组件搭建的版本配置化
这里的配置化指的是在构建镜像 (docker build) 的时候可指定，升级版本不需要修改脚本代码

### java工程, 支持在 dockerfile 中指定依赖下载路径
节省空间

## 最后，欢迎大家一起交流一起学习！
如果你对镜像或者这个仓库有任何疑问，都欢迎直接通过 issue 直接提问题和建议