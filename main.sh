#!/bin/bash

# ===== 颜色定义（用于终端美化输出）=====
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
NC='\033[0m'   # 恢复默认颜色

# ===== 加载配置文件 =====
# 配置文件中定义了日志路径等信息
if [ ! -f "./config.conf" ]; then
    echo -e "${RED}缺少配置文件 config.conf${NC}"
    exit 1
fi
source ./config.conf

# ===== 获取参数 =====
DIR=$1        # 要处理的目录
MODE=$2       # 操作模式：type / date / all
DRY=$3        # 是否为 dry-run 模式

# ===== 参数校验 =====
if [ -z "$DIR" ] || [ -z "$MODE" ]; then
    echo -e "${RED}用法: ./main.sh 目录 [type|date|all] [dry]${NC}"
    exit 1
fi

echo -e "${BLUE}===== 文件管理系统启动 =====${NC}"

# ===== 调用环境检查脚本 =====
./checker.sh "$DIR"

# ===== 记录开始时间 =====
start_time=$(date +%s)

# ===== 日志函数 =====
# 参数1：日志级别（INFO/ERROR）
# 参数2：日志内容
log(){
    ./logger.sh "$LOGFILE" "$1" "$2"
}

# ===== 文件移动函数 =====
# 支持 dry-run（只打印不执行）
run_move(){
    src="$1"
    dst="$2"

    if [ "$DRY" = "dry" ]; then
        echo -e "${YELLOW}[DRY-RUN] $src -> $dst${NC}"
    else
        mv "$src" "$dst"
    fi
}

# ===== 检查目录是否为空 =====
check_empty(){
    files=("$1"/*)
    if [ ${#files[@]} -eq 0 ] || [ ! -e "${files[0]}" ]; then
        echo -e "${YELLOW}目录 '$1' 中没有文件${NC}"
        exit 0
    fi
}

count=0   # 文件计数器

# ===== 核心功能选择 =====
case $MODE in

# ===== 按文件类型整理 =====
type)
    echo -e "${YELLOW}按类型整理中...${NC}"

    check_empty "$DIR"

    for file in "$DIR"/*; do
        [ -f "$file" ] || continue   # 跳过非文件

        name=$(basename "$file")

        # 获取扩展名
        if [[ "$name" == *.* ]]; then
            ext="${name##*.}"
        else
            ext="others"   # 无扩展名归类
        fi

        target="$DIR/$ext"
        mkdir -p "$target"   # 创建目录

        run_move "$file" "$target/$name"
        ((count++))
    done

    log "INFO" "类型整理完成，共$count个文件"
    ;;

# ===== 按日期整理 =====
date)
    echo -e "${YELLOW}按日期整理中...${NC}"

    check_empty "$DIR"

    for file in "$DIR"/*; do
        [ -f "$file" ] || continue

        # 获取文件修改时间
        d=$(stat -c %y "$file" | cut -d' ' -f1)

        # 拆分 年/月/日
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

# ===== 组合模式（先type再date）=====
all)
    echo -e "${YELLOW}组合模式执行中...${NC}"

    check_empty "$DIR"

    # 先按类型分类
    ./main.sh "$DIR" type

    # 再对子目录按日期分类
    for sub in "$DIR"/*; do
        [ -d "$sub" ] && ./main.sh "$sub" date
    done

    log "INFO" "组合整理完成"
    ;;

# ===== 参数错误处理 =====
*)
    echo -e "${RED}参数错误${NC}"
    exit 1
    ;;
esac

# ===== 记录结束时间 =====
end_time=$(date +%s)
duration=$((end_time - start_time))

# ===== 输出执行结果 =====
echo -e "${GREEN}✔ 完成，用时 ${duration}s${NC}"