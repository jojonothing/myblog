# 根据负载动态调整线程
MAX_THREADS=$(nproc)
CURRENT_LOAD=$(awk '{print $1}' /proc/loadavg | cut -d. -f1)
USABLE_THREADS=$(( MAX_THREADS - CURRENT_LOAD ))
--threads $(( USABLE_THREADS > 1 ? USABLE_THREADS : 1 )) 