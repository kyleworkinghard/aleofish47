#!/bin/bash

# 定义监控间隔时间，单位为秒
interval=60

# 获取当前运行的 aleominer 进程命令
get_miner_command() {
    miner_command=$(ps -eo args | grep "[/]aleominer" | head -n 1)
    if [ -z "$miner_command" ]; then
        echo "未找到正在运行的挖矿程序"
    else
        echo "当前挖矿程序的命令是: $miner_command"
    fi
}

# 启动后等待30秒再开始检查
echo "程序启动后等待 30 秒..."
sleep 30

# 检查并获取当前的挖矿程序命令
get_miner_command

# 如果未找到运行的挖矿程序，则使用默认命令启动挖矿程序
if [ -z "$miner_command" ]; then
    miner_command="nohup ./aleominer -u stratum+tcp://aleo-asia.f2pool.com:4400 -d 0 -w kyle30.kyle001 >> ./aleominer.log 2>&1 &"
    echo "启动默认挖矿命令: $miner_command"
    eval $miner_command
else
    echo "挖矿程序已运行，使用获取到的命令: $miner_command"
fi

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

            # 重新获取当前挖矿程序的启动命令
            get_miner_command

            # 如果找到挖矿命令，则重新启动挖矿程序
            if [ ! -z "$miner_command" ]; then
                echo "重启挖矿程序，命令为: $miner_command"
                eval nohup $miner_command >> ./aleominer.log 2>&1 &
                echo "挖矿程序已重启"
            else
                echo "未找到挖矿程序命令，使用默认命令重新启动"
                miner_command="nohup ./aleominer -u stratum+tcp://aleo-asia.f2pool.com:4400 -d 0 -w kyle30.kyle001 >> ./aleominer.log 2>&1 &"
                eval $miner_command
            fi
        else
            echo "GPU使用率正常: ${gpu_util}%"
        fi

        # 等待指定的间隔时间
        sleep $interval
    done
}

# 运行监控函数
monitor_gpu

