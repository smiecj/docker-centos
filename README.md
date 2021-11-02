# docker-centos
提供一个centos开发镜像

## 使用方式
docker build -f docker-centos/Dockerfiles/centos

### 可通过 ADMIN_PWD=pwd 设定 root 用户登录密码
### --privileged 是必选项，因为系统需要初始化root 账户相关服务和权限
docker run --name centos --env "ADMIN_PWD=root!centos123" -d --privileged -p 2222:22 mzsmieli/centos_dev

然后 本地就可以直接连接到centos 镜像了:
ssh root@root!centos123 -p 2222

## 项目目录
scripts: 放到开发镜像中的脚本

## 待规划需求
可以在 docker run 中输入组件名，自动安装对应组件
如: docker run --env "INSTALL_PLUGINS=zookeeper,mysql"

## 最后，欢迎大家一起交流一起学习！
如果你对镜像或者这个仓库有任何疑问，都欢迎直接通过 issue 直接提问题和建议