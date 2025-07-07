#!/bin/sh
. "$(dirname $0)/env.sh"
example_path="$ROOT"/example
APP_NAME="Meeting"
OUTPUT_DIR="$example_path/build/output"
mkdir -p "$OUTPUT_DIR"
cd "$example_path"

# 检测CPU架构
ARCH=$(uname -m)
case $ARCH in
    x86_64)
        FLUTTER_ARCH="x64"
        ;;
    aarch64|arm64)
        FLUTTER_ARCH="arm64"
        ;;
    *)
        echo "不支持的架构: $ARCH"
        exit 1
        ;;
esac

echo "检测到架构: $ARCH, Flutter架构: $FLUTTER_ARCH"

echo "构建 linux 包"
flutter build linux

echo "压缩 linux 包"
BUNDLE_DIR="$example_path/build/linux/$FLUTTER_ARCH/release/bundle"
if [ ! -d "$BUNDLE_DIR" ]; then
    echo "错误: 构建目录不存在: $BUNDLE_DIR"
    exit 1
fi

cd "$BUNDLE_DIR"
rm -rf "$example_path"/build/linux/meeting_flutter.tar.gz
tar -czvf "$example_path"/build/linux/meeting_flutter.tar.gz *
mv -f "$example_path"/build/linux/meeting_flutter.tar.gz "$OUTPUT_DIR/meeting_flutter_linux_${FLUTTER_ARCH}.tar.gz"

echo "构建 AppImage (允许失败)"
APPDIR="$example_path/build/appimage/$APP_NAME.AppDir"
if "$script_dir/linux_appimage.sh"; then
    echo "AppImage 构建成功"
    if [ -f "$example_path/build/linux/Meeting.AppImage" ]; then
        mv -f "$example_path/build/linux/Meeting.AppImage" "$OUTPUT_DIR/meeting_flutter_linux_${FLUTTER_ARCH}.AppImage"
        echo "AppImage 已移动到输出目录: meeting_flutter_linux_${FLUTTER_ARCH}.AppImage"
        
        echo "压缩 AppImage 生成的胖包"
        if [ -d "$APPDIR" ]; then
            cd "$APPDIR"
            rm -rf "$example_path"/build/linux/meeting_flutter_fat.tar.gz
            tar -czvf "$example_path"/build/linux/meeting_flutter_fat.tar.gz *
            mv -f "$example_path"/build/linux/meeting_flutter_fat.tar.gz "$OUTPUT_DIR/meeting_flutter_linux_fat_${FLUTTER_ARCH}.tar.gz"
            echo "胖包已压缩: meeting_flutter_linux_fat_${FLUTTER_ARCH}.tar.gz"
        else
            echo "警告: AppDir 目录不存在，跳过胖包压缩"
        fi
    else
        echo "警告: AppImage 文件未找到，跳过移动"
    fi
else
    echo "警告: AppImage 构建失败，但继续其他构建步骤"
fi

echo "构建完成! 输出文件:"
echo "- meeting_flutter_linux_${FLUTTER_ARCH}.tar.gz (基础包)"
if [ -f "$OUTPUT_DIR/meeting_flutter_linux_${FLUTTER_ARCH}.AppImage" ]; then
    echo "- meeting_flutter_linux_${FLUTTER_ARCH}.AppImage (自包含单文件)"
fi
if [ -f "$OUTPUT_DIR/meeting_flutter_linux_fat_${FLUTTER_ARCH}.tar.gz" ]; then
    echo "- meeting_flutter_linux_fat_${FLUTTER_ARCH}.tar.gz (自包含胖包)"
fi