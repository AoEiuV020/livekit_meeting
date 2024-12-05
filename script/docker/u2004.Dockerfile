# 使用 Ubuntu 20.04 作为基础镜像
FROM ubuntu:20.04

# 避免交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# 设置时区
ENV TZ=Asia/Shanghai

# 更新系统并安装基础工具
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    sudo \
    python3 \
    python3-pip \
    cmake \
    ninja-build \
    pkg-config \
    clang \
    # deb打包相关
    dpkg-dev \
    debhelper \
    # 清理缓存
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 安装 linuxdeploy 相关
RUN wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage \
    && chmod +x linuxdeploy-x86_64.AppImage \
    && mv linuxdeploy-x86_64.AppImage /usr/local/bin/linuxdeploy

# 安装 flatpak 相关
RUN apt-get update && apt-get install -y \
    flatpak \
    flatpak-builder \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 安装 Flutter SDK
RUN git clone --depth 1 --branch 3.24.5 https://github.com/flutter/flutter.git /opt/flutter \
    && /opt/flutter/bin/flutter doctor

# 设置 Flutter 环境变量
ENV PATH="/opt/flutter/bin:${PATH}"

# 安装 Flutter Linux 开发依赖
RUN apt-get update && apt-get install -y \
    libgtk-3-dev \
    liblzma-dev \
    libstdc++-10-dev \
    && flutter precache --linux \
    && flutter doctor -v \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 安装项目依赖 libmpv-dev
RUN apt-get update && apt-get install -y \
    libmpv-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 创建用户 developer (UID=1000)
RUN useradd -m -u 1000 -s /bin/bash developer \
    && echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 设置 flutter 目录权限
RUN chown -R developer:developer /opt/flutter

# 创建工作目录
RUN mkdir -p /workspace && chown developer:developer /workspace

# 切换到 developer 用户
USER developer
WORKDIR /workspace

# 设置用户缓存目录
RUN mkdir -p /home/developer/.pub-cache

# 禁用flutter cli动画
RUN flutter config --no-cli-animations

# 安装全局dart包
RUN dart pub global activate melos
ENV PATH="/home/developer/.pub-cache/bin:${PATH}"


# 创建并设置 entrypoint 脚本
USER root
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# 切换回 developer 用户
USER developer

# 设置 entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["echo", "打包完成，请查看容器内输出目录：/workspace/example/build/output"]