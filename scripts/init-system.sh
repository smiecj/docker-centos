#!/bin/bash
set -euxo pipefail

## 系统初始化脚本，主要包括：初始化系统、预装软件等

### 设置root账号密码
yum -y install expect

root_pwd="root!centos123"
if [ $# -eq 1 ]; then
    root_pwd=$1
fi

/home/coding/scripts/expect-pwd.exp $root_pwd

### 安装组件
#### 后续实现

