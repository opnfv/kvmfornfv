#!/bin/bash

qemu_pid=`ps -ef | grep qemu | grep -v grep | awk '{print \$2}'| sed -e 's/ //g' | sed -e 's/\r//g'`

processors=`taskset -cp ${qemu_pid}|awk -F ':' '{print $2}' | sed -e 's/\r//g' `


timeout=5m
ARGS="--cpu=5"

./stress_scripts.sh -c ${processors} -t $timeout -a $ARGS
