#!/bin/bash

# Exit current daemon.

set -o xtrace

MYDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $MYDIR/../host-config

function br-iov {
	ovs-ofctl del-flows br0
	ovs-vsctl add-port br0 dpdk0 -- set Interface dpdk0 type=dpdk
	ovs-vsctl add-port br0 dpdk1 -- set Interface dpdk1 type=dpdk
	# The test flows
	ovs-ofctl add-flow br0 in_port=1,action=output:2
	ovs-ofctl add-flow br0 in_port=2,action=output:1
	ovs-vsctl set Interface dpdk0 options:n_rxq=1
	ovs-vsctl set Interface dpdk1 options:n_rxq=1
}

function br-vhost {
	ovs-vsctl add-port br0 dpdk0 -- set Interface dpdk0 type=dpdk
	ovs-vsctl add-port br0 dpdk1 -- set Interface dpdk1 type=dpdk
	 ovs-vsctl add-port br0 vhost-user-1 -- set Interface vhost-user-1 	type=dpdkvhostuser
	 ovs-vsctl add-port br0 vhost-user-2 -- set Interface vhost-user-2 	type=dpdkvhostuser
	ovs-ofctl add-flow br0 in_port=1,action=output:3
	ovs-ofctl add-flow br0 in_port=3,action=output:1
	ovs-ofctl add-flow br0 in_port=2,action=output:4
	ovs-ofctl add-flow br0 in_port=4,action=output:2
}

function clean_oldenv { 
	ovs-vsctl --if-exists del-br  br0
	ovs-appctl exit
	# Seems can't kill ovs dbserver clearly, so kill it by force
	ovs_dbserver_pid=`ps aux |grep ovsdb-server |grep pidfile | awk '{print $2}'`
	echo "ovs_dbserver_pid is $ovs_dbserver_pid"
	kill $ovs_dbserver_pid
	`ps aux |grep "ovs-vswitchd" |grep dpdk`
	if [ $? -eq 0 ]
	then
		echo "Failed to stop vswitch daemon"
		exit 1
	fi
	rm /usr/local/etc/openvswitch/conf.db
}

ARGS=1
E_BADARGS=85
if [ $# -ne "$ARGS" ]
then
	echo "Usage: `basename $0` envmode(host/guest)"
	exit $E_BADARGS
fi
if [ "$1" != "host" ] && [ "$1" != "guest" ]
then
	echo "Envmode must be host or guest"
	exit $E_BADARGS
fi

envmode="$1"


clean_oldenv

ovsdb-tool create /usr/local/etc/openvswitch/conf.db /usr/local/share/openvswitch/vswitch.ovsschema

ovsdb-server --remote=punix:/usr/local/var/run/openvswitch/db.sock \
    --remote=db:Open_vSwitch,Open_vSwitch,manager_options \
    --pidfile --detach

ovs-vsctl --no-wait init

export DB_SOCK=/usr/local/var/run/openvswitch/db.sock

# What's the impact of the -c parameter, which is dpdk parameter, to ovs switchd? 
ovs-vswitchd --dpdk -n 2 -c 0x2000000 --socket-mem 0,16384 -- unix:$DB_SOCK --pidfile --detach


cpumask () {
    m=$((1<<${1}))
    printf 0x%x ${m}
}

m=0
function get_pmdmask {
	for i in $pmd_cpus; do
		mask=`cpumask $i`
		echo "cpu is $i and mask is $mask m is $m"
		m=$(($m | $mask))
	done
	pmd_cpus=`printf %x  ${m}`
}
get_pmdmask

ovs-vsctl set Open_vSwitch . other_config:pmd-cpu-mask=$pmd_cpus
ovs-vsctl set Open_vSwitch . other_config:n-handler-threads=1
ovs-vsctl set Open_vSwitch . other_config:n-revalidator-threads=1

ovs-vsctl add-br br0 -- set bridge br0 datapath_type=netdev

if [ "$envmode" == 'host' ]
then
    br-iov
else
    br-vhost
fi

source ./ovs-pinthreads.sh

source ./ovs-dumpenv.sh

set +o xtrace
