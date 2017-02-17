#!/bin/bash

set -o xtrace
TRACE_FILE=trace.txt
TRACEDIR=/sys/kernel/debug/tracing

sudo bash -c "cat $TRACEDIR/trace > /tmp/$TRACE_FILE"
sudo bash -c "echo 0 >$TRACEDIR/tracing_on"
sleep 1
sudo bash -c "echo > $TRACEDIR/set_event"
sudo bash -c "echo > $TRACEDIR/trace"
sudo sysctl kernel.ftrace_enabled=0
sudo bash -c "echo nop > $TRACEDIR/current_tracer"

set +o xtrace
