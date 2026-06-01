#!/bin/bash

# ===== 打印报告标题 =====
echo "===== 文件整理报告 ====="
echo "时间: $(date)"

# ===== 统计总文件数 =====
TOTAL=$(find . -type f | wc -l)
echo "总文件数: $TOTAL"

# ===== 统计文件类型 =====
find . -type f | awk -F. '{print $NF}' | sort | uniq -c | sort -nr > tmp_type_count.txt

# ===== Python生成柱状图 =====
python3 - <<END
import matplotlib.pyplot as plt

types, counts = [], []
with open("tmp_type_count.txt") as f:
    for line in f:
        parts = line.strip().split()
        if len(parts) == 2:
            counts.append(int(parts[0]))
            types.append(parts[1])

plt.bar(types, counts, color='skyblue')
plt.xlabel('文件类型')
plt.ylabel('数量')
plt.title('文件类型统计')
plt.savefig('file_type_chart.png')
plt.close()
print("图表已保存为 file_type_chart.png")
END

# ===== 自动打开图表（MobaXterm/X11）=====
if command -v xdg-open >/dev/null 2>&1; then
    xdg-open file_type_chart.png
elif command -v display >/dev/null 2>&1; then
    display file_type_chart.png
else
    echo "无法自动打开图片，请查看 file_type_chart.png"
fi

# ===== 打印类型统计 =====
echo ""
echo "按类型统计:"
cat tmp_type_count.txt

# ===== 显示最近日志 =====
echo ""
echo "最近日志:"
tail -n 5 log.txt

rm tmp_type_count.txt