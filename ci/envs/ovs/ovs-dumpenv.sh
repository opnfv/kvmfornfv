#!/bin/bash

MYDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $MYDIR/../host-config

function dumpcmd {
	echo "# $1"
	$1
}

function dumpqemu {
	i=`ps aux |grep "qemu" |wc -l`
	if [ $i -lt 2 ]
        then
		echo "No qemu process found"
		return
	fi
	qemu_pid=`ps aux |grep "qemu" |grep kvm |awk '{print $2}'`
	echo "#qemu command:"
	# Will qemu be created without netdev? No idea :)
	ps aux |grep "qemu" |grep "netdev"
	dumpcmd "taskset  -a -p $qemu_pid"
}

function dumphost {
	dumpcmd "cat /proc/cmdline"
	vswitchd_pid=`ps aux |grep "ovs-vswitchd" |grep dpdk |awk '{print $2}'`
	echo "vswitch daemon is $vswitchd_pid"
	echo "vswitch daemon command"
	# We should always detach th daemon
	ps aux |grep "ovs-vswitchd" |grep "detach"
	dumpcmd "ovs-vsctl show"
	dumpcmd "ovs-ofctl dump-flows br0"
	dumpcmd "ps -T -p $vswitchd_pid"
	dumpcmd "taskset  -a -p $vswitchd_pid"
	dumpcmd "ovs-appctl dpif-netdev/pmd-stats-show"
}

dumphost
dumpqemu
