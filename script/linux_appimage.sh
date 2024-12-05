#!/bin/sh
. "$(dirname $0)/env.sh"
example_path="$ROOT"/example
# 设置变量
APP_NAME="Meeting"
BUNDLE_DIR="$example_path/build/linux/x64/release/bundle"
APPDIR="$example_path/build/appimage/$APP_NAME.AppDir"
APP_ICON="$example_path/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_256.png"
OUTPUT_DIR="$example_path/build/output"
cd "$APPDIR/.."

# 创建 AppDir 目录结构
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin"
mkdir -p "$APPDIR/usr/lib"
mkdir -p "$APPDIR/usr/share/applications"
mkdir -p "$APPDIR/usr/share/icons/hicolor/256x256/apps"

# 复制应用程序文件
rm -rf "$APPDIR/usr/bin/*"
cp -r "$BUNDLE_DIR"/* "$APPDIR/usr/bin/"

# 创建 .desktop 文件
cat > "$APPDIR/usr/share/applications/$APP_NAME.desktop" << EOF
[Desktop Entry]
Name=$APP_NAME
Exec=AppRun
Icon=$APP_NAME
Type=Application
Categories=Utility;
EOF

# 复制图标文件
cp "$APP_ICON" "$APPDIR/usr/share/icons/hicolor/256x256/apps/$APP_NAME.png"

# 创建 AppRun 文件
cat > "$APPDIR/AppRun" << EOF
#!/bin/sh
cd "\$(dirname "\$0")/usr/bin"
exec "./meeting_flutter_example" "\$@"
EOF

# 设置执行权限
chmod +x "$APPDIR/AppRun"

# 构建 AppImage
export NO_STRIP=true
linuxdeploy --appdir "$APPDIR" --output appimage

mv -f "./$APP_NAME.AppImage" "$OUTPUT_DIR/$APP_NAME.AppImage"

# 清理临时文件
# rm -rf "$APPDIR"

echo "AppImage 构建完成！: "
