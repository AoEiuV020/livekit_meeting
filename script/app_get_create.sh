#!/bin/sh
. "$(dirname $0)/env.sh"

name=$1
# name 传入了包名就在apps创建包，否则创建修改根项目，
createProject() {
    expect <<EOF
spawn sh -c "get create project:\"$1\""
expect "Select which type of project you want to create ?"
send "1\r"
expect "What is your company's domain?"
send "$organization\r"
expect "What language do you want to use on ios?"
send "1\r"
expect "What language do you want to use on android?"
send "1\r"
expect "Do you want to use some linter?"
send "1\r"
expect "Which architecture do you want to use?"
send "1\r"
expect "WARNING: This action is irreversible"
send "1\r"
expect eof
exit
EOF
}
if [ -z "$name" ] || [ "$name" = "." ]; then
    cd "$ROOT"
    rm -f pubspec.yaml README.md
    mv .gitignore .gitignore.bak
    createProject .
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
    createProject "$name"
    cd "$name"
fi
echo 'include: package:flutter_lints/flutter.yaml' >analysis_options.yaml
cat "$script_dir"/analyzer_custom.yaml >>analysis_options.yaml
"$script_dir"/prepare.sh
