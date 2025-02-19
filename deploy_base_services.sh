# 添加资源检查
if [ $(free -m | awk '/Mem:/ {print $2}') -lt 1024 ]; then
    echo "内存不足，至少需要 1GB 内存" >&2
    exit 1
fi

# 添加磁盘空间检查
MIN_DISK=2048 # 2GB
if [ $(df -m . | awk 'NR==2 {print $4}') -lt $MIN_DISK ]; then
    echo "磁盘空间不足，需要至少 ${MIN_DISK}MB" >&2
    exit 1
fi

# 添加依赖检查
required_commands=(awk free systemctl)
for cmd in "${required_commands[@]}"; do
    if ! command -v $cmd &> /dev/null; then
        echo "依赖命令缺失: $cmd" >&2
        exit 1
    fi
done 