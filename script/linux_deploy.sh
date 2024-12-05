#!/bin/sh
. "$(dirname $0)/env.sh"
example_path="$ROOT"/example
cd "$example_path"
flutter build linux
cd "$example_path"/build/linux/x64/release/bundle
rm -rf "$example_path"/build/linux/meeting_flutter.tar.gz
tar -czvf "$example_path"/build/linux/meeting_flutter.tar.gz *
mv -f "$example_path"/build/linux/meeting_flutter.tar.gz "$example_path"/build/output/meeting_flutter_linux.tar.gz

"$script_dir/linux_appimage.sh"
mv -f "$example_path"/build/linux/Meeting-x86_64.AppImage "$example_path"/build/output/meeting_flutter_linux.AppImage

cd "$example_path"/build/linux/Meeting.AppDir
rm -rf "$example_path"/build/linux/meeting_flutter_fat.tar.gz
tar -czvf "$example_path"/build/linux/meeting_flutter_fat.tar.gz *
mv -f "$example_path"/build/linux/meeting_flutter_fat.tar.gz "$example_path"/build/output/meeting_flutter_linux_fat.tar.gz

# meeting_flutter_linux.tar.gz docker ubuntu 20.04 打包,
# meeting_flutter_linux_fat.tar.gz docker ubuntu 20.04 打包, 自带动态库，
# meeting_flutter_linux.AppImage docker ubuntu 20.04 打包，自带动态库，AppImage单文件，
# meeting.flatpak 虚拟机 archlinux 打包，