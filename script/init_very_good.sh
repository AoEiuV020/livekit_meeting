#!/bin/sh
. "$(dirname $0)/env.sh"

# 检查是否安装了 very_good_cli 命令
if ! command -v very_good_cli > /dev/null; then
    echo "very_good_cli is not installed. Installing..."
    dart pub global activate very_good_cli
    if [[ ":$PATH:" != *":$HOME/.pub-cache/bin:"* ]]; then
        export PATH="$PATH:$HOME/.pub-cache/bin"
    fi
fi
