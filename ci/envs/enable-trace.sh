#!/bin/bash

set -o xtrace
EVENT=$1
curpwd=`pwd`
TRACEDIR=/sys/kernel/debug/tracing/
rm -rf /tmp/trace.txt

function getcpumask {
        masks=`lscpu | grep "NUMA node1 CPU(s)"| awk -F ':' '{print \$2}' | sed 's/[[:space:]]//g'`
        first=$(echo ${masks} | cut -f1 -d-)
        last=$(echo ${masks} | cut -f2 -d-)
	cpumask=0
        while [ ${first} -lt ${last} ]; do
                cputmp=`echo "ibase=10; obase=16; 2^(${first})" | bc`
                cpumask=`echo "ibase=16; obase=10; ${cputmp}+${cpumask}" |bc`
                first=`expr $first + 1`
	done
	highvalue=`echo "ibase=16;obase=10;$cpumask/(2^20)" |bc `
	lowvalue=`echo "ibase=16;obase=10;$cpumask%(2^20)" |bc `
	CPUMASK=`printf '%08x,%08x' 0x$highvalue 0x$lowvalue`
}

getcpumask
sudo bash -c "echo $CPUMASK > $TRACEDIR/tracing_cpumask"

#sudo bash -c "echo function > $TRACEDIR/current_tracer"
#echo :* > set_event
#echo $EVENT:* > set_event

sudo bash -c "echo 1 > $TRACEDIR/events/irq/enable"
sudo bash -c "echo 1 > $TRACEDIR/events/irq_vectors/enable"
sudo bash -c "echo 1 > $TRACEDIR/events/task/enable"
sudo bash -c "echo 1 > $TRACEDIR/events/syscalls/enable"
sudo bash -c "echo 1 > $TRACEDIR/events/kmem/enable"
sudo bash -c "echo 1 > $TRACEDIR/events/fence/enable"
sudo bash -c "echo 1 > $TRACEDIR/events/context_tracking/enable"
sudo bash -c "echo 1 > $TRACEDIR/events/exceptions/enable"
sudo bash -c "echo 1 > $TRACEDIR/events/irq_vectors/enable"
sudo bash -c "echo 1 > $TRACEDIR/events/nmi/enable"
sudo bash -c "echo 1 > $TRACEDIR/events/kmem/enable"
sudo bash -c "echo 1 > $TRACEDIR/events/migrate/enable"
sudo bash -c "echo 1 > $TRACEDIR/events/sock/enable"
sudo bash -c "echo 1 > $TRACEDIR/events/timer/enable"
sudo bash -c "echo 1 > $TRACEDIR/events/sched/enable"
sudo bash -c "echo 1 > $TRACEDIR/events/rcu/enable"
sudo bash -c "echo 1 > $TRACEDIR/events/kvm/enable"
sudo bash -c "echo 1 > $TRACEDIR/events/workqueue/enable"
sudo bash -c "echo 1 > $TRACEDIR/events/power/enable"
sudo bash -c "echo 1 > $TRACEDIR/events/signal/enable"

sudo bash -c "echo 1 > events/tlb/enable"

# Clean original log info
sudo bash -c "echo > $TRACEDIR/trace"
sudo bash -c "echo function > $TRACEDIR/current_tracer"
sudo sysctl kernel.ftrace_enabled=1
#echo 0 >tracing_on; sleep 1; echo 1 >tracing_on; sleep 20; echo 0 >tracing_on;sleep 1; cat trace >/tmp/123.txt
sudo bash -c "echo 1 >$TRACEDIR/tracing_on"

cd $curpwd
set +o xtrace
