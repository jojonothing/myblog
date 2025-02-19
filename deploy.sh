#!/bin/bash

# 设置错误时退出
set -e

# 日志函数
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# 错误处理函数
handle_error() {
    log "错误发生在第 $1 行"
    exit 1
}

trap 'handle_error $LINENO' ERR

# 检查环境
log "检查环境..."
if ! command -v hugo > /dev/null; then
    log "错误: Hugo 未安装"
    exit 1
fi

if ! command -v nginx > /dev/null; then
    log "错误: Nginx 未安装"
    exit 1
fi

# 在检查环境后添加资源预检
check_resources() {
    local required_resources=(
        "assets/media/images/default2.jpg"
        "content/_index.md"
        "themes/dream/assets/css/main.css"
    )
    
    for res in "${required_resources[@]}"; do
        if [ ! -f "$res" ]; then
            log "关键资源缺失: $res"
            return 1
        fi
    done
}

# 修改主流程
main() {
    check_environment
    check_resources || exit 18
    # ...原有流程...
}

# 创建备份
log "创建备份..."
BACKUP_DIR="backup/$(date +'%Y%m%d_%H%M%S')"
if [ -d "public" ]; then
    mkdir -p "$BACKUP_DIR"
    if ! cp -r public "$BACKUP_DIR"; then
        log "错误: 备份创建失败"
        exit 3
    fi
    # 添加备份校验
    if [ ! -d "$BACKUP_DIR/public" ] || [ ! -f "$BACKUP_DIR/public/index.html" ]; then
        log "错误: 备份验证失败，缺少关键文件"
        exit 4
    fi
fi

# 清理并重新创建 public 目录
log "清理 public 目录..."
rm -rf public
mkdir -p public
chmod 775 public
sudo chown $USER:www-data public

# 在生成站点前添加资源同步
log "同步静态资源..."
rsync -av --delete \
    assets/media/images/ \
    content/images/ \
    static/images/ \
    public/images/

# 修改Hugo构建命令
log "生成站点..."
hugo_build() {
    local hugo_log="hugo_build_$(date +%s).log"
    hugo --minify --templateMetrics --logLevel debug 2>&1 | tee "$hugo_log"
    
    # 分析构建日志
    grep -E 'WARN|ERROR' "$hugo_log" | grep -iE 'image|resource' && {
        log "检测到资源处理问题，启用备用方案..."
        rsync -av content/images/ public/images/
    }
    
    rm "$hugo_log"
}
hugo_build || {
    log "Hugo生成失败"
    exit 10
}

# 确保权限正确
log "设置权限..."
find public -type d -exec chmod 775 {} \;
find public -type f -exec chmod 664 {} \;
sudo chown -R $USER:www-data public

# 增强验证逻辑
verify_generated_files() {
    local missing_files=()
    local gen_files=(
        "public/index.html"
        "public/images/default2.jpg"
        "public/css/custom.css"
    )
    
    # 添加文件哈希验证
    declare -A file_hashes=(
        ["public/images/default2.jpg"]="a1b2c3d4"
        ["public/css/custom.css"]="e5f6g7h8"
    )
    
    for file in "${gen_files[@]}"; do
        if [ ! -f "$file" ]; then
            log "生成文件缺失: $file"
            missing_files+=("$file")
        elif [[ -v file_hashes[$file] ]]; then
            actual_hash=$(md5sum "$file" | cut -d' ' -f1)
            if [[ "${file_hashes[$file]}" != "$actual_hash" ]]; then
                log "文件校验失败: $file (预期: ${file_hashes[$file]}, 实际: $actual_hash)"
                missing_files+=("$file")
            fi
        fi
    done
    
    [ ${#missing_files[@]} -eq 0 ] && return 0 || return 1
}

# 检查生成的文件
log "验证生成的文件..."
required_files=(
    "public/index.html"
    "public/images/default2.jpg"
    "public/css/custom.css"
)
for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        log "错误: 必需文件缺失 - $file"
        exit 5
    fi
done

# 重启 nginx
log "重启 Nginx..."
sudo systemctl restart nginx

# 验证网站可访问性
log "验证网站可访问性..."
MAX_RETRY=3
for ((i=1; i<=$MAX_RETRY; i++)); do
    if curl -sSf --max-time 10 http://localhost > /dev/null; then
        break
    fi
    sleep 5
done

log "部署完成！"
