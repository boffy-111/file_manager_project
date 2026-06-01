#!/bin/bash

# ===== 颜色 =====
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
NC='\033[0m'

# ===== 加载配置 =====
[ ! -f "./config.conf" ] && echo -e "${RED}缺少配置文件${NC}" && exit 1
source ./config.conf

DIR=$1
MODE=$2
DRY=$3

# ===== 参数检查 =====
if [ -z "$DIR" ] || [ -z "$MODE" ]; then
    echo -e "${RED}用法: ./main.sh 目录 [type|date|all] [dry]${NC}"
    exit 1
fi

echo -e "${BLUE}===== 文件管理系统启动 =====${NC}"

# ===== 环境检查 =====
./checker.sh "$DIR"

start_time=$(date +%s)

# ===== 日志 =====
log(){
    ./logger.sh "$LOGFILE" "$1" "$2"
}

# ===== 移动函数 =====
run_move(){
    src="$1"
    dst="$2"

    if [ "$DRY" = "dry" ]; then
        echo -e "${YELLOW}[DRY-RUN] $src -> $dst${NC}"
    else
        mv "$src" "$dst"
    fi
}

# ===== 空目录检测 =====
check_empty(){
    files=("$1"/*)
    if [ ${#files[@]} -eq 0 ] || [ ! -e "${files[0]}" ]; then
        if [ "$DRY" = "dry" ]; then
            echo -e "${YELLOW}[DRY-RUN] 目录 '$1' 中没有文件${NC}"
        else
            echo -e "${YELLOW}目录 '$1' 中没有文件${NC}"
        fi
        exit 0
    fi
}

count=0

# ===== 功能选择 =====
case $MODE in

type)
    echo -e "${YELLOW}按类型整理中...${NC}"

    check_empty "$DIR"

    for file in "$DIR"/*; do
        [ -f "$file" ] || continue

        name=$(basename "$file")

        if [[ "$name" == *.* ]]; then
            ext="${name##*.}"
        else
            ext="others"
        fi

        target="$DIR/$ext"
        mkdir -p "$target"

        run_move "$file" "$target/$name"
        ((count++))
    done

    log "INFO" "类型整理完成，共$count个文件"
    ;;

date)
    echo -e "${YELLOW}按日期整理中...${NC}"

    check_empty "$DIR"

    for file in "$DIR"/*; do
        [ -f "$file" ] || continue

        d=$(stat -c %y "$file" | cut -d' ' -f1)
        y=$(echo $d | cut -d- -f1)
        m=$(echo $d | cut -d- -f2)
        d2=$(echo $d | cut -d- -f3)

        target="$DIR/$y/$m/$d2"
        mkdir -p "$target"

        run_move "$file" "$target/$(basename "$file")"
        ((count++))
    done

    log "INFO" "日期整理完成，共$count个文件"
    ;;

all)
    echo -e "${YELLOW}组合模式执行中...${NC}"

    check_empty "$DIR"

    # 先按类型
    ./main.sh "$DIR" type

    # 再按日期
    for sub in "$DIR"/*; do
        [ -d "$sub" ] && ./main.sh "$sub" date
    done

    log "INFO" "组合整理完成"
    ;;

*)
    echo -e "${RED}参数错误${NC}"
    exit 1
    ;;
esac

end_time=$(date +%s)
time=$((end_time - start_time))

echo -e "${GREEN}✔ 完成，用时 ${time}s${NC}"