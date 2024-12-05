#!/bin/sh
. "$(dirname $0)/env.sh"
example_path="$ROOT"/example

# 检查依赖
check_dependency() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "错误: 未找到 $1，请先安装。"
        echo "在 Arch Linux 上运行: sudo pacman -S $2"
        echo "然后重新运行此脚本"
        exit 1
    fi
}

check_flatpak_runtime() {
    if ! flatpak info org.freedesktop.Platform//23.08 >/dev/null 2>&1; then
        echo "错误: 未找到 Flatpak 运行时。"
        echo "请运行以下命令安装必要的运行时："
        echo "sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo"
        echo "sudo flatpak install flathub org.freedesktop.Platform//23.08 org.freedesktop.Sdk//23.08"
        echo "然后重新运行此脚本"
        exit 1
    fi
}

# 检查必要的依赖
check_dependency "flatpak" "flatpak"
check_dependency "flatpak-builder" "flatpak-builder"
check_dependency "eu-strip" "elfutils"

# 检查 Flatpak 运行时
check_flatpak_runtime

# 设置变量
APP_NAME="Meeting"
OUTPUT_DIR="$example_path/build/output"
APPDIR="$example_path/build/appimage/$APP_NAME.AppDir"
APPIMAGE_FILE="$OUTPUT_DIR/$APP_NAME.AppImage"
FLATPAK_BUILD_DIR="$example_path/build/flatpak"

# 检查 AppImage 文件是否存在
if [ ! -f "$APPIMAGE_FILE" ]; then
    echo "错误: AppImage 文件不存在: $APPIMAGE_FILE"
    echo "请先运行 linux_appimage.sh 生成 AppImage"
    exit 1
fi

# 创建构建目录
rm -rf "$FLATPAK_BUILD_DIR"
FLATPAK_BUNDLE_DIR="$FLATPAK_BUILD_DIR/bundle"
mkdir -p "$FLATPAK_BUNDLE_DIR/bin"
mkdir -p "$FLATPAK_BUNDLE_DIR/share/applications"
mkdir -p "$FLATPAK_BUNDLE_DIR/share/icons/hicolor/256x256/apps"

# 复制 AppImage 文件
cp "$APPIMAGE_FILE" "$FLATPAK_BUNDLE_DIR/bin/meeting"
chmod +x "$FLATPAK_BUNDLE_DIR/bin/meeting"

# 创建 desktop 文件
cat > "$FLATPAK_BUNDLE_DIR/share/applications/com.chat.weichat.Meeting.desktop" << EOF
[Desktop Entry]
Name=$APP_NAME
Exec=meeting
Icon=com.chat.weichat.Meeting
Type=Application
Categories=Utility;
EOF

# 复制图标
cp "$APPDIR/usr/share/icons/hicolor/256x256/apps/$APP_NAME.png" "$FLATPAK_BUNDLE_DIR/share/icons/hicolor/256x256/apps/com.chat.weichat.Meeting.png"

# 创建 manifest 文件
cat > "$FLATPAK_BUILD_DIR/com.chat.weichat.Meeting.yml" << EOF
app-id: com.chat.weichat.Meeting
runtime: org.freedesktop.Platform
runtime-version: '23.08'
sdk: org.freedesktop.Sdk
command: meeting
finish-args:
  - --share=ipc
  - --socket=x11
  - --socket=wayland
  - --filesystem=host
  - --device=dri
  - --share=network
modules:
  - name: meeting
    buildsystem: simple
    build-commands:
      - mkdir -p /app/bin
      - cp bin/meeting /app/bin/
      - chmod +x /app/bin/meeting
      - cp -r share /app/
    sources:
      - type: dir
        path: bundle
EOF

# 构建 Flatpak
cd "$FLATPAK_BUILD_DIR"
flatpak-builder --force-clean --repo=repo build-dir com.chat.weichat.Meeting.yml
flatpak build-bundle repo meeting.flatpak com.chat.weichat.Meeting

mv meeting.flatpak "$OUTPUT_DIR/meeting.flatpak"
echo "Flatpak 构建完成！" 

echo "安装: flatpak install --user $OUTPUT_DIR/meeting.flatpak"
echo "运行: flatpak run com.chat.weichat.Meeting"