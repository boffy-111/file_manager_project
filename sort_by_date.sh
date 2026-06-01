#!/bin/bash

DIR=$1

if [ ! -d "$DIR" ]; then
    echo "目录不存在"
    exit 1
fi

count=0

for file in "$DIR"/*; do
    if [ -f "$file" ]; then
        
        date=$(stat -c %y "$file" | cut -d' ' -f1)

        year=$(echo $date | cut -d- -f1)
        month=$(echo $date | cut -d- -f2)
        day=$(echo $date | cut -d- -f3)

        target="$DIR/$year/$month/$day"
        mkdir -p "$target"

        filename=$(basename "$file")

        # 防止重名
        if [ -e "$target/$filename" ]; then
            filename="$(date +%s)_$filename"
        fi

        mv "$file" "$target/$filename"
        ((count++))
    fi
done

echo "按日期整理完成，共处理 $count 个文件"