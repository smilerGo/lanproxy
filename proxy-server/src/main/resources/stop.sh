#!/bin/bash

# 进入部署目录
cd `dirname $0`
# BIN_DIR=`pwd`
cd ..

# 获取部署目录
DEPLOY_DIR=`pwd`

# 日志目录为部署目录下的logs文件夹
LOGS_DIR=$DEPLOY_DIR/logs

# 如果日志目录不存在，则创建日志目录
if [ ! -d $LOGS_DIR ]; then
    mkdir $LOGS_DIR
fi

# 标准输出文件为日志目录下的stdout.log文件
STDOUT_FILE=$LOGS_DIR/stdout.log

# 获取正在运行的进程的PID
PID=`ps -ef | grep -v grep | grep "$DEPLOY_DIR/conf" | awk '{print $2}'`

# 输出PID
echo "PID: $PID"

# 如果PID为空，则表示代理服务器未启动
if [ -z "$PID" ]; then
    echo "ERROR: 代理服务器未启动！"
    exit 1
fi

# 输出停止代理服务器的提示，并在每次输出后清除终端屏幕
echo -e "停止代理服务器...\c"

# 杀死进程，并将输出结果保存到标准输出文件中
kill $PID > $STDOUT_FILE 2>&1

# 初始化计数器
COUNT=0

# 循环检测进程是否已停止
while [ $COUNT -lt 1 ]; do
    # 输出停止进度，并在每次输出后清除终端屏幕
    echo -e ".\c"
    sleep 1
    COUNT=1

    # 检测进程是否还存在
    PID_EXIST=`ps -f -p $PID | grep java`
    if [ -n "$PID_EXIST" ]; then
        COUNT=0
    fi
done

# 代理服务器已停止
echo "已停止"

# 输出最终的PID
echo "PID: $PID"
