#!/bin/bash
. "$(dirname $0)/env.sh"

# 检查 ROOT 环境变量是否已定义
if [ -z "$ROOT" ]; then
  echo "请定义 ROOT 环境变量！"
  exit 1
fi

echo "ROOT: $ROOT"

# 定义两个架构
ARCHITECTURES=("amd64" "arm64")

# 构建和运行两个架构的容器
for ARCH in "${ARCHITECTURES[@]}"; do
    echo "=========================================="
    echo "处理架构: $ARCH"
    echo "=========================================="
    
    # 设置变量
    IMAGE_NAME="flutter-build-$ARCH"
    CONTAINER_NAME="flutter-container-$ARCH"
    DOCKER_PLATFORM="linux/$ARCH"
    
    # 清理已存在的容器
    if docker ps -a --format "table {{.Names}}" | grep -q "^$CONTAINER_NAME$"; then
        echo "删除已存在的容器: $CONTAINER_NAME"
        docker rm -f "$CONTAINER_NAME"
    fi
    
    # 构建镜像
    echo "构建 $ARCH 镜像..."
    # 必须pull否则会复用已有某个架构的基础镜像导致切换架构无效，
    docker build --platform="$DOCKER_PLATFORM" \
        --pull \
        -t "$IMAGE_NAME" \
        -f "$ROOT/script/docker/u2004.Dockerfile" \
        "$ROOT/script/docker"
    
    if [ $? -ne 0 ]; then
        echo "错误：$ARCH 镜像构建失败"
        continue
    fi
    
    # 运行容器
    echo "运行 $ARCH 容器..."
    time docker run --rm \
        --name "$CONTAINER_NAME" \
        --platform="$DOCKER_PLATFORM" \
        -v "$ROOT:/workspace" \
        -v "$HOME/.pub-cache/:/home/developer/.pub-cache/" \
        "$IMAGE_NAME"
    
    if [ $? -ne 0 ]; then
        echo "警告：$ARCH 容器运行失败"
    else
        echo "$ARCH 容器运行完成"
    fi
    
    echo ""
done

echo "所有架构处理完成"
