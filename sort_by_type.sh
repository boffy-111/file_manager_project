#!/bin/bash

DIR=$1

if [ ! -d "$DIR" ]; then
    echo "目录不存在"
    exit 1
fi

count=0

for file in "$DIR"/*; do
    if [ -f "$file" ]; then
        
        filename=$(basename "$file")
        ext="${filename##*.}"

        # 无后缀处理
        if [[ "$filename" != *.* ]]; then
            ext="others"
        fi

        target="$DIR/$ext"
        mkdir -p "$target"

        # 防止覆盖
        if [ -e "$target/$filename" ]; then
            filename="$(date +%s)_$filename"
        fi

        mv "$file" "$target/$filename"
        ((count++))
    fi
done

echo "按类型整理完成，共处理 $count 个文件"