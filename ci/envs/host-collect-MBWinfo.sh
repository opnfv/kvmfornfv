#!/bin/bash
#This script is used to collect the memory read and write information using pcm memory tool
testtype=$2
testName=$1
echo 0 > /proc/sys/kernel/nmi_watchdog
echo "Running PCM memory to collect memory bandwidth"
if [ ! -d "/root/MBWInfo" ]; then
mkdir -p /root/MBWInfo
fi
pcm_memory=/root/pcm/pcm-memory.x
timeStamp=$(date +%Y-%m-%d-%H-%M-%S)
${pcm_memory} 15 &>/root/MBWInfo/MBWInfo_${testName}_${testtype}_${timeStamp} &disown
pid=$(ps aux | grep 'pcm' | awk '{print $2}' | head -1)
echo "PCM tool is running on the pid:$pid"
