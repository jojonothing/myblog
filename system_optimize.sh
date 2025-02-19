# 添加 ZRAM 配置
sudo apt install zram-config -y

# 动态计算ZRAM大小
MEMORY_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
ZRAM_SIZE=$(( ($MEMORY_KB * 3) / 4 ))K  # 使用内存的75%

# 兼容不同发行版
if [[ -f /etc/debian_version ]]; then
    sudo systemctl restart zram-config
elif [[ -f /etc/redhat-release ]]; then
    sudo systemctl restart zramd
fi

# 优化ZRAM参数
echo "zram" > /etc/modules-load.d/zram.conf
echo "options zram num_devices=1" > /etc/modprobe.d/zram.conf
echo "KERNEL==\"zram0\", ATTR{disksize}=\"$(($(free -m | awk '/Mem:/ {print $2}')/2))M\", TAG+=\"systemd\"" > /etc/udev/rules.d/99-zram.rules 