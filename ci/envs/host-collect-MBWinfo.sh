#!/bin/bash
#This script is used to collect the memory read and write information using pcm memory tool
testtype=$2
testName=$1
echo "Running PCM memory to collect memory bandwidth"
mkdir /root/MBWInfo
pcm_memory=/root/pcm/pcm-memory.x
timeStamp=$(date +%Y-%m-%d-%H-%M-%S)
${pcm_memory} 60 &>/root/MBWInfo/MBWInfo_${testName}_${testType}_${timeStamp} &disown
pid=$(ps aux | grep 'pcm' | awk '{print \$2}' | head -1)
echo "PCM tool is running on the pid:$pid"
