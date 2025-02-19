# 添加完整性校验
if ! tar -tf $backup_file &> /dev/null; then
    echo "备份文件损坏！" >&2
    exit 1
fi

# 添加哈希校验
backup_hash=$(sha256sum $backup_file | awk '{print $1}')
stored_hash=$(cat ${backup_file}.sha256)

if [ "$backup_hash" != "$stored_hash" ]; then
    echo "备份文件哈希校验失败" >&2
    exit 2
fi

# 添加关键文件存在性检查
if ! tar -tf $backup_file | grep -q "etc/nginx/nginx.conf"; then
    echo "关键配置文件缺失" >&2
    exit 3
fi 