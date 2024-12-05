#!/bin/sh
. "$(dirname $0)/env.sh"
example_path="$ROOT"/example
APP_NAME="Meeting"
APPDIR="$example_path/build/appimage/$APP_NAME.AppDir"
OUTPUT_DIR="$example_path/build/output"
mkdir -p "$OUTPUT_DIR"
cd "$example_path"

echo "构建 linux 包"
flutter build linux

echo "压缩 linux 包"
cd "$example_path"/build/linux/x64/release/bundle
rm -rf "$example_path"/build/linux/meeting_flutter.tar.gz
tar -czvf "$example_path"/build/linux/meeting_flutter.tar.gz *
mv -f "$example_path"/build/linux/meeting_flutter.tar.gz "$example_path"/build/output/meeting_flutter_linux.tar.gz

echo "构建 AppImage"
"$script_dir/linux_appimage.sh"

echo "压缩 AppImage 生成的胖包"
cd "$APPDIR"
rm -rf "$example_path"/build/linux/meeting_flutter_fat.tar.gz
tar -czvf "$example_path"/build/linux/meeting_flutter_fat.tar.gz *
mv -f "$example_path"/build/linux/meeting_flutter_fat.tar.gz "$example_path"/build/output/meeting_flutter_linux_fat.tar.gz

# meeting_flutter_linux.tar.gz docker ubuntu 20.04 打包,
# meeting_flutter_linux_fat.tar.gz docker ubuntu 20.04 打包, 自带动态库，
# meeting_flutter_linux.AppImage docker ubuntu 20.04 打包，自带动态库，AppImage单文件，