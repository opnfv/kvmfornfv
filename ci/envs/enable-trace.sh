#!/bin/bash

set -o xtrace
EVENT=$1
curpwd=`pwd`
TRACEDIR=/sys/kernel/debug/tracing

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
bash -c "echo $CPUMASK > $TRACEDIR/tracing_cpumask"

#sudo bash -c "echo function > $TRACEDIR/current_tracer"
#echo :* > set_event
#echo $EVENT:* > set_event

bash -c "echo 1 > $TRACEDIR/events/irq/enable"
bash -c "echo 1 > $TRACEDIR/events/irq_vectors/enable"
bash -c "echo 1 > $TRACEDIR/events/task/enable"
bash -c "echo 1 > $TRACEDIR/events/syscalls/enable"
bash -c "echo 1 > $TRACEDIR/events/kmem/enable"
bash -c "echo 1 > $TRACEDIR/events/fence/enable"
bash -c "echo 1 > $TRACEDIR/events/context_tracking/enable"
bash -c "echo 1 > $TRACEDIR/events/exceptions/enable"
bash -c "echo 1 > $TRACEDIR/events/irq_vectors/enable"
bash -c "echo 1 > $TRACEDIR/events/nmi/enable"
bash -c "echo 1 > $TRACEDIR/events/kmem/enable"
bash -c "echo 1 > $TRACEDIR/events/migrate/enable"
bash -c "echo 1 > $TRACEDIR/events/sock/enable"
bash -c "echo 1 > $TRACEDIR/events/timer/enable"
bash -c "echo 1 > $TRACEDIR/events/sched/enable"
bash -c "echo 1 > $TRACEDIR/events/rcu/enable"
bash -c "echo 1 > $TRACEDIR/events/kvm/enable"
bash -c "echo 1 > $TRACEDIR/events/workqueue/enable"
bash -c "echo 1 > $TRACEDIR/events/power/enable"
bash -c "echo 1 > $TRACEDIR/events/signal/enable"

bash -c "echo 1 > events/tlb/enable"

# Clean original log info
bash -c "echo > $TRACEDIR/trace"
bash -c "echo function > $TRACEDIR/current_tracer"
sysctl kernel.ftrace_enabled=1
#echo 0 >tracing_on; sleep 1; echo 1 >tracing_on; sleep 20; echo 0 >tracing_on;sleep 1; cat trace >/tmp/123.txt
bash -c "echo 1 >$TRACEDIR/tracing_on"

cd $curpwd
set +o xtrace
