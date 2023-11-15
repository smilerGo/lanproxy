#!/bin/bash

# 进入部署目录
cd `dirname $0`
cd ..         # 进入上级目录
DEPLOY_DIR=`pwd`         # 获取当前目录路径并保存到变量DEPLOY_DIR中

# 初始化配置和日志目录
CONF_DIR=$DEPLOY_DIR/conf         # 配置目录路径保存到变量CONF_DIR中
LOGS_DIR=$DEPLOY_DIR/logs         # 日志目录路径保存到变量LOGS_DIR中

# 设置应用主类
APP_MAIN_CLASS=org.fengfei.lanproxy.server.ProxyServerContainer

# 获取已经运行的进程号
PIDS=`ps -ef | grep -v grep | grep "$CONF_DIR" |awk '{print $2}'`

# 如果已经运行，则输出错误信息并退出
if [ -n "$PIDS" ]; then
    echo "ERROR: already started!"
    echo "PID: $PIDS"
    exit 1
fi

# 如果日志目录不存在，则创建
if [ ! -d $LOGS_DIR ]; then
    mkdir $LOGS_DIR
fi

# 定义标准输出和垃圾收集日志文件路径
STDOUT_FILE=$LOGS_DIR/stdout.log
#CLOG_FILE=$LOGS_DIR/gc.log

# 初始化库目录和库文件路径
LIB_DIR=$DEPLOY_DIR/lib
LIB_JARS=`ls $LIB_DIR|grep .jar|awk '{print "'$LIB_DIR'/"$0}'| xargs | sed "s/ /:/g"`

# 设置Java选项
JAVA_OPTS=" -Djava.awt.headless=true -Djava.net.preferIPv4Stack=true  -Djdk.tls.rejectClientInitiatedRenegotiation=true"
JAVA_DEBUG_OPTS=""
# 如果命令行参数为"debug"，则设置Java调试选项
if [ "$1" = "debug" ]; then
    JAVA_DEBUG_OPTS=" -Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n "
fi
JAVA_JMX_OPTS=""
# 如果命令行参数为"jmx"，则设置Java JMX选项
if [ "$1" = "jmx" ]; then
    JAVA_JMX_OPTS=" -Dcom.sun.management.jmxremote.port=1099 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false "
fi

# 设置Java内存选项
JAVA_MEM_OPTS=""

# 启动代理服务器
echo -e "Starting the proxy server ...\c"
nohup java -Dapp.home=$DEPLOY_DIR $JAVA_OPTS $JAVA_MEM_OPTS $JAVA_DEBUG_OPTS $JAVA_JMX_OPTS -classpath $CONF_DIR:$LIB_JARS $APP_MAIN_CLASS >$STDOUT_FILE 2>&1 &
sleep 1
echo "started"

# 获取正在运行的进程号
PIDS=`ps -ef | grep java | grep "$DEPLOY_DIR" | awk '{print $2}'`

# 输出进程号
echo "PID: $PIDS"
