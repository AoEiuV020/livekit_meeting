#!/bin/sh
. "$(dirname $0)/env.sh"
example_path="$ROOT"/example

# 检查依赖
check_dependency() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "错误: 未找到 $1，请先安装。"
        echo "在 Ubuntu/Debian 上运行: sudo apt-get install $2"
        echo "在 Arch Linux 上运行: sudo pacman -S $2"
        echo "然后重新运行此脚本"
        exit 1
    fi
}

# 检查并安装 linuxdeploy
install_linuxdeploy() {
    if ! command -v linuxdeploy >/dev/null 2>&1; then
        echo "正在安装 linuxdeploy..."
        check_dependency "wget" "wget"
        sudo wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage -O /usr/local/bin/linuxdeploy
        sudo chmod +x /usr/local/bin/linuxdeploy
        if ! command -v linuxdeploy >/dev/null 2>&1; then
            echo "错误: linuxdeploy 安装失败"
            exit 1
        fi
        echo "linuxdeploy 安装成功"
    fi
}

# 检查必要的依赖
check_dependency "wget" "wget"
install_linuxdeploy

# 设置变量
APP_NAME="Meeting"
BUNDLE_DIR="$example_path/build/linux/x64/release/bundle"
APPDIR="$example_path/build/appimage/$APP_NAME.AppDir"
APP_ICON="$example_path/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_256.png"
OUTPUT_DIR="$example_path/build/output"

# 检查必要文件是否存在
if [ ! -d "$BUNDLE_DIR" ]; then
    echo "错误: 构建目录不存在: $BUNDLE_DIR"
    echo "请先运行 flutter build linux 构建应用"
    exit 1
fi

if [ ! -f "$APP_ICON" ]; then
    echo "错误: 应用图标不存在: $APP_ICON"
    exit 1
fi

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

echo "创建 AppDir 目录结构"
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin"
mkdir -p "$APPDIR/usr/lib"
mkdir -p "$APPDIR/usr/share/applications"
mkdir -p "$APPDIR/usr/share/icons/hicolor/256x256/apps"

cd "$APPDIR/.."

echo "复制应用程序文件"
rm -rf "$APPDIR/usr/bin/*"
cp -r "$BUNDLE_DIR"/* "$APPDIR/usr/bin/"

echo "创建 .desktop 文件"
cat > "$APPDIR/usr/share/applications/$APP_NAME.desktop" << EOF
[Desktop Entry]
Name=$APP_NAME
Exec=AppRun
Icon=$APP_NAME
Type=Application
Categories=Utility;
EOF

echo "复制图标文件"
cp "$APP_ICON" "$APPDIR/usr/share/icons/hicolor/256x256/apps/$APP_NAME.png"

echo "创建 AppRun 文件"
cat > "$APPDIR/AppRun" << EOF
#!/bin/sh
cd "\$(dirname "\$0")/usr/bin"
exec "./meeting_flutter_example" "\$@"
EOF

echo "设置执行权限"
chmod +x "$APPDIR/AppRun"

echo "构建 AppImage"
# export NO_STRIP=true
linuxdeploy --appdir "$APPDIR" --output appimage

if [ $? -ne 0 ]; then
    echo "错误: AppImage 构建失败"
    exit 1
fi

mv -f "./$APP_NAME"*.AppImage "$OUTPUT_DIR/$APP_NAME.AppImage"

# 清理临时文件
# rm -rf "$APPDIR"

echo "AppImage 构建完成！输出文件位置: $OUTPUT_DIR/$APP_NAME.AppImage"
