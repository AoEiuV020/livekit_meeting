#!/bin/sh
. "$(dirname $0)/env.sh"

# 检查是否安装了 get_cli 命令
if ! command -v get_cli > /dev/null; then
    echo "get_cli is not installed. Installing..."
    dart pub global activate -s git https://github.com/jonataslaw/get_cli
    if [[ ":$PATH:" != *":$HOME/.pub-cache/bin:"* ]]; then
        export PATH="$PATH:$HOME/.pub-cache/bin"
    fi
fi
