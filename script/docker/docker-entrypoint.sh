#!/bin/bash
set -e

cd /workspace

echo "获取依赖"
flutter pub get
echo "初始化项目"
flutter pub run melos bootstrap

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