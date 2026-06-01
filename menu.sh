#!/bin/bash

# ===== 颜色定义 =====
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
NC='\033[0m'

clear
echo -e "${BLUE}==================================${NC}"
echo -e "${GREEN}   文件管理系统（菜单版）${NC}"
echo -e "${BLUE}==================================${NC}"

# ===== 输入处理目录 =====
read -p "请输入要整理的目录: " DIR
[ ! -d "$DIR" ] && echo -e "${RED}目录不存在！${NC}" && exit 1

# ===== 循环菜单 =====
while true; do
    echo ""
    echo -e "${YELLOW}请选择操作:${NC}"
    echo "1. 按类型整理"
    echo "2. 按日期整理"
    echo "3. 组合整理（type + date）"
    echo "4. dry-run 模式（模拟执行）"
    echo "5. 查看报告"
    echo "0. 退出"

    read -p "请输入选项: " choice

    case $choice in
        1) ./main.sh "$DIR" type ;;  # 调用 main.sh 类型整理
        2) ./main.sh "$DIR" date ;;  # 调用 main.sh 日期整理
        3) ./main.sh "$DIR" all ;;   # 调用 main.sh 组合整理
        4)
            echo "选择 dry-run 模式："
            echo "1. type"
            echo "2. date"
            read -p "请选择: " drychoice
            case $drychoice in
                1) ./main.sh "$DIR" type dry ;;
                2) ./main.sh "$DIR" date dry ;;
                *) echo -e "${RED}无效选项${NC}" ;;
            esac
            ;;
        5) ./report.sh ;;  # 调用报告脚本
        0)
            echo -e "${BLUE}已退出系统${NC}"
            exit 0
            ;;
        *) echo -e "${RED}输入错误，请重新选择${NC}" ;;
    esac

    echo ""
    read -p "按回车键返回菜单..." temp
    clear
done