# 可配置化阈值
RESPONSE_THRESHOLD=${1:-2.0}  # 允许通过参数设置阈值

# 添加日志轮转
if [ $(wc -l < /var/log/service_response.csv) -gt 10000 ]; then
    mv /var/log/service_response.csv /var/log/service_response.$(date +%Y%m%d).csv
fi

# 添加重试机制
MAX_RETRY=3
TIMEOUT=5
for ((i=1; i<=MAX_RETRY; i++)); do
    response_time=$(curl --max-time $TIMEOUT -o /dev/null -s -w '%{time_total}\n' http://localhost:8080/health)
    [ $? -eq 0 ] && break
    sleep 1
done

# 添加历史数据记录
echo "$(date +%s),$response_time" >> /var/log/service_response.csv

if (( $(echo "$response_time > $RESPONSE_THRESHOLD" | bc -l) )); then
    echo "服务响应超时：${response_time}s" >&2
fi 