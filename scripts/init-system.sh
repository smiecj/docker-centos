#!/bin/bash
set -euxo pipefail

## 系统初始化脚本，主要包括：初始化系统、预装软件等

### 设置root账号密码

#### 默认密码: root!centos123
root_pwd="root!centos123"
if [ "" != "$ROOT_PWD" ]; then
    root_pwd=$ROOT_PWD
fi

echo root:$root_pwd | chpasswd

exec /usr/sbin/init

### 安装组件
#### 后续实现
