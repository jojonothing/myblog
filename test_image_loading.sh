#!/bin/bash
# 图片加载测试脚本
TEST_URL=${1:-http://localhost}
TIMEOUT=10

check_image() {
    local img_path=$1
    if ! curl -sSf --max-time $TIMEOUT -o /dev/null "$TEST_URL$img_path"; then
        echo "图片加载失败: $img_path"
        return 1
    fi
    return 0
}

# 测试关键图片
declare -a critical_images=(
    "/images/default2.jpg"
    "/images/logo.png"
    "/images/fallback.webp"
)

# 在性能测试前添加完整性检查
check_image_integrity() {
    local img=$1
    if [ ! -f "public$img" ]; then
        echo "本地文件缺失: $img"
        return 2
    fi
    
    local file_type=$(file -b --mime-type "public$img")
    if [[ ! $file_type =~ image/ ]]; then
        echo "文件类型异常: $img (实际类型: $file_type)"
        return 3
    fi
}

# 修改测试循环
for img in "${critical_images[@]}"; do
    check_image_integrity "$img" || exit 2
    check_image "$img" || exit 1
done

# 性能测试
echo "响应时间测试:"
curl -o /dev/null -sS -w "
HTTP状态码: %{http_code}
总时间: %{time_total}s
DNS解析: %{time_namelookup}s
建立连接: %{time_connect}s
SSL握手: %{time_appconnect}s 
开始传输: %{time_starttransfer}s
" "$TEST_URL/images/default2.jpg"

# 添加预检模式
if [[ "$1" == "--precheck" ]]; then
    echo "执行部署前资源检查..."
    required_sources=(
        "content/images/default2.jpg"
        "assets/media/images/default2.jpg"
    )
    
    for src in "${required_sources[@]}"; do
        if [ ! -f "$src" ]; then
            echo "源文件缺失: $src"
            exit 5
        fi
    done
    exit 0
fi

# 在测试开始前调用
./test_image_loading.sh --precheck 