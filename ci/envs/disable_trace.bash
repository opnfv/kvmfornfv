#!/bin/bash

set -o xtrace
curpwd=`pwd`
TRACE_FILE=trace.txt
TRACEDIR=/sys/kernel/debug/tracing

echo 0 > $TRACEDIR/tracing_on
sleep 1
cat $TRACEDIR/trace > /tmp/$TRACE_FILE

echo > $TRACEDIR/set_event
echo > $TRACEDIR/trace
sysctl kernel.ftrace_enabled=0
echo nop > $TRACEDIR/current_tracer

set +o xtrace
cd $curpwd
