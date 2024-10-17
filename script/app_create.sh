#!/bin/sh
. "$(dirname $0)/env.sh"

name=$1
# name 传入了包名就在apps创建包，否则创建修改根项目，
if [ -z "$name" ] || [ "$name" = "." ]; then
    cd "$ROOT"
    rm -f pubspec.yaml README.md
    mv .gitignore .gitignore.bak
    flutter create --org "$organization" --template=app .
    dart pub add dev:melos
    cat .gitignore.bak >>.gitignore
    rm -f .gitignore.bak
else
    # 检查并创建目录
    if [ ! -d "$apps_dir" ]; then
        echo "Directory $apps_dir does not exist. Creating..."
        mkdir -p "$apps_dir"
    fi
    cd "$apps_dir"
    flutter create --org "$organization" --template=app "$name"
    cd "$name"
fi
echo 'include: package:flutter_lints/flutter.yaml' >analysis_options.yaml
cat "$script_dir"/analyzer_custom.yaml >>analysis_options.yaml
"$script_dir"/prepare.sh
