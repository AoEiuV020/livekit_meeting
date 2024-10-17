#!/bin/sh
. "$(dirname $0)/env.sh"

name=$1
exec=$2
# name 传入了包名就在packages创建包，否则创建修改根项目，
# exec 默认使用dart, 可以改flutter,
if [ -z "$name" ] || [ "$name" = "." ]; then
    cd "$ROOT"
    rm -f pubspec.yaml README.md
    mv .gitignore .gitignore.bak
    if [ "$exec" = "flutter" ]; then
        flutter create --template=package .
    else
        dart create --template=package --force .
    fi
    dart pub add dev:melos
    cat .gitignore.bak >>.gitignore
    rm -f .gitignore.bak
else
    # 检查并创建目录
    if [ ! -d "$packages_dir" ]; then
        echo "Directory $packages_dir does not exist. Creating..."
        mkdir -p "$packages_dir"
    fi
    cd "$packages_dir"
    if [ "$exec" = "flutter" ]; then
        flutter create --template=package "$name"
    else
        dart create --template=package "$name"
    fi
    cd "$name"
fi
if [ "$exec" = "flutter" ]; then
    echo 'include: package:flutter_lints/flutter.yaml' >analysis_options.yaml
else
    echo 'include: package:lints/recommended.yaml' >analysis_options.yaml
fi
cat "$script_dir"/analyzer_custom.yaml >>analysis_options.yaml
"$script_dir"/prepare.sh
