#!/bin/bash

# 定义监控间隔时间，单位为秒
interval=60

# 监控函数
monitor_gpu() {
    while true; do
        # 获取GPU使用率 (只获取第0号GPU的使用率)
        gpu_util=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | head -n 1)
        
        # 如果GPU使用率小于80，重启挖矿程序
        if [ "$gpu_util" -lt 80 ]; then
            echo "GPU使用率低于80%，重启挖矿程序..."

            # 强制停止当前挖矿进程
            pkill -9 aleominer

            # 重启挖矿程序
            nohup ./aleominer -u stratum+tcp://aleo-asia.f2pool.com:4400 -d 0 -w kyle10.kyle001 >> ./aleominer.log 2>&1 &

            echo "挖矿程序已重启"
        else
            echo "GPU使用率正常: ${gpu_util}%"
        fi
        
        # 等待指定的间隔时间
        sleep $interval
    done
}

# 运行监控函数
monitor_gpu

