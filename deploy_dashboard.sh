#!/bin/bash
# 添加前置检查
if ! command -v whiptail &> /dev/null; then
    echo "whiptail 未安装，使用基础模式部署" >&2
    exec ./deploy_base_services.sh && ./deploy_nginx.sh && ./deploy_ai_service.sh
    exit $?
fi

# 增强进度计算逻辑
declare -A STEP_WEIGHTS=(
    [pre_check]=10
    [deploy_base_services.sh]=25
    [deploy_nginx.sh]=20
    [deploy_ai_service.sh]=30
    [post_check]=15
)
TOTAL_WEIGHT=$((10+25+20+30+15))

# 添加进度百分比计算
total_steps=4
current_step=0

# 添加部署后检查
post_deployment_check() {
    local error_count=0
    curl -sSf http://localhost/health >/dev/null || ((error_count++))
    [ -f "public/images/default2.jpg" ] || ((error_count++))
    return $error_count
}

{
    progress=0
    ./deploy_base_services.sh && progress=$((progress + 25))
    ./deploy_nginx.sh && progress=$((progress + 20)) 
    ./deploy_ai_service.sh && progress=$((progress + 30))
} | tee -a deploy.log | whiptail --title "部署进度" --gauge "正在初始化..." 6 60 0 