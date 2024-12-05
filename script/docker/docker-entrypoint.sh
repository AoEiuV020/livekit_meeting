#!/bin/bash
set -e

cd /workspace

# 检查并执行准备脚本
if [ -f "script/prepare.sh" ]; then
    echo "Running prepare script..."
    bash script/prepare.sh
fi

# 删除已存在的 linux build 目录
# echo "Deleting existing linux build directory..."
# rm -rf example/build/linux/x64/release

# 检查并执行部署脚本
if [ -f "script/linux_deploy.sh" ]; then
    echo "Running linux deploy script..."
    bash script/linux_deploy.sh
fi

# 执行传入的命令或者启动 bash
exec "$@" 