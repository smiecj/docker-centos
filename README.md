# docker-centos
提供一个centos开发镜像

## 使用方式
### 构建开发镜像
docker build -f docker-centos/Dockerfiles/centos_dev -t centos_dev .

docker run -d --privileged=true -p 2222:22 centos_dev /usr/sbin/init

### 构建存储镜像
docker build -f docker-centos/Dockerfiles/centos_storage -t centos_storage .

docker run -d --privileged=true -p 3306:3306 centos_storage /usr/sbin/init

### 构建 jupyter 镜像
docker build -f docker-centos/Dockerfiles/centos_jupyter -t centos_jupyter .

docker run -d --privileged=true -p 8000:8000 centos_jupyter /usr/sbin/init

### 构建 lab 镜像
docker build -f docker-centos/Dockerfiles/centos_jupyterlab -t centos_jupyterlab .

docker run -d --privileged=true -p 8000:80 centos_jupyterlab /usr/sbin/init

### 构建 hue 镜像
docker build -f docker-centos/Dockerfiles/centos_hue -t centos_hue .

### 构建 wordpress 镜像
docker build --build-arg MYSQL_ADDR=mysql_addr --build-arg MYSQL_USER=mysql_user --build-arg MYSQL_PASSWORD=mysql_password --no-cache -f Dockerfiles/centos_wordpress -t centos_wordpress .

docker run -d --privileged=true -p 8000:80 centos_wordpress /usr/sbin/init

### docker build: 可通过 ADMIN_PWD=pwd 设定 root 用户登录密码
示例: docker build --build-arg ROOT_PWD=root_Test123 --no-cache -f Dockerfiles/centos_dev -t centos_dev .

### docker run: --privileged 和 /usr/sbin/init 是必选项，因为系统需要初始化 root 账户相关服务和权限
docker run -d --privileged=true -p 2222:22 centos_dev /usr/sbin/init

然后 本地就可以直接连接到centos 镜像了:
ssh root@root!centos123 -p 2222

## 项目目录
scripts: 放到开发镜像中的脚本

Dockerfiles: 存放各个开发用到的 DockerFile

## 待规划需求
### centos_dev DockerFile 支持自定义需要安装的环境/组件
可以在 docker run 中输入组件名，自动安装对应组件
如: docker run --env "INSTALL_PLUGINS=zookeeper,mysql"

### zookeeper 集群的本地部署
通过 K8S 搭建zk 集群

## 最后，欢迎大家一起交流一起学习！
如果你对镜像或者这个仓库有任何疑问，都欢迎直接通过 issue 直接提问题和建议