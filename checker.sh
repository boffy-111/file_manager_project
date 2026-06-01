#!/bin/bash

DIR=$1

# 检查目录
if [ ! -d "$DIR" ]; then
    echo "错误：目录不存在"
    exit 1
fi

# 检查权限
if [ ! -w "$DIR" ]; then
    echo "错误：没有写权限"
    exit 1
fi

# 检查命令依赖
for cmd in mv mkdir stat date; do
    if ! command -v $cmd &>/dev/null; then
        echo "缺少命令: $cmd"
        exit 1
    fi
done

echo "环境检查通过"