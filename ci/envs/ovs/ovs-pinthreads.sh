#!/bin/bash

MYDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $MYDIR/../host-config

cpumask () {
    m=$((1<<${1}))
    printf 0x%x ${m}
}

vswitchd_pid=`ps aux |grep "ovs-vswitchd" |grep detach |awk '{print $2}'`

rev_pid=`ps -T -p "$vswitchd_pid" | grep "revalidator" | awk '{print $2}'`
handler_pid=`ps -T -p "$vswitchd_pid" | grep "handler" |awk '{print $2}'`
vhost_thread_pid=`ps -T -p "$vswitchd_pid" | grep "vhost_thread" |awk '{print $2}'`
urcu_thread_pid=`ps -T -p "$vswitchd_pid" | grep "urcu" |awk '{print $2}'`
dpdk_watchdog_pid=`ps -T -p "$vswitchd_pid" | grep "dpdk_watchdog" |awk '{print $2}'`

echo "$rev_pid $handler_pid $vswitchd_pid"

i=0
for c in $misc_cpus; do
    cpu[$i]=${c}
    i=`expr $i + 1`
done

i=0
# Yes, it's overkill to pin all of them so separatedly */
for tid in "$vswitchd_pid" "$rev_pid" "$handler_pid" "$vhost_thread_pid" "$urcu_thread_pid" "$dpdk_watchdog_pid" ; do
	mask=`cpumask ${cpu[$i]}`
	taskset -p ${mask} ${tid}
	i=`expr $i + 1`
done
