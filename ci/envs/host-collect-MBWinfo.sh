#!/bin/bash
#This script is used to collect the memory read and write information using pcm memory tool
testtype=$2
testName=$1
echo 0 > /proc/sys/kernel/nmi_watchdog
echo "Running PCM memory to collect memory bandwidth"
timeStamp=$(date +%Y-%m-%d-%H-%M-%S)
if [ ! -d "/root/MBWInfo" ]; then
mkdir -p /root/MBWInfo/MBWInfo_${testName}_${testtype}_${timeStamp}
fi
pcm_memory=/root/pcm/pcm-memory.x
${pcm_memory} 30 -csv &>/root/MBWInfo/MBWInfo_${testName}_${testtype}_${timeStamp}/MBWInfo_${testName}.csv &disown
pid=$(ps aux | grep 'pcm' | awk '{print $2}' | head -1)
echo "PCM tool is running on the pid:$pid"
