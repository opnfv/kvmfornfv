#!/bin/bash

#############################################################################
#Copyright (c) 2015 Huawei Technologies Co.,Ltd and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

source host-config
OVSLOGFILE="/usr/local/var/run/openvswitch/ovs-vswitchd.log"
HOME='/home/jenkins'
VSPERF="${HOME}/vswitchperf"

function install_ovsdpdk() {
 #Installing ovs dpdk using vsperf environment
 echo "Installing ovs dpdk using vsperf environment"
 install_vsperf
 setup_ovsdpdk
}
function install_vsperf() {
 echo "Installing vsperf....."
 ( cd $VSPERF/systems ; ./build_base_machine.sh )
 if [ ${?} -ne 0 ]; then
    echo "Execution of build_base_machine.sh failed"
    exit 1
 fi
}
function setup_ovsdpdk() {
 sudo mkdir -p /usr/local/var/run/openvswitch
 sudo mkdir -p /usr/local/etc/openvswitch
 sudo modprobe openvswitch
 
 #Kill the ovsswitch and ovsdbserver
 cd $VSPERF/src/ovs/ovs
 ps aux | grep 'ovsdb-server.pid' | awk '{print $2}' | head -1 | xargs kill -SIGTERM
 ps aux | grep 'ovs-vswitchd.pid' | awk '{print $2}' | head -1 | xargs kill -SIGTERM
 kill -SIGTERM 39424
 
 rm -f /usr/local/var/run/openvswitch/vhost-user*
 rm -f /usr/local/etc/openvswitch/conf.db
 
 #Start database server
 echo "Start ovs database server"
 export DB_SOCK=/usr/local/var/run/openvswitch/db.sock
 cd $VSPERF/src/ovs/ovs/ovsdb
 sudo ./ovsdb-tool create /usr/local/etc/openvswitch/conf.db $VSPERF/src/ovs/ovs/vswitchd/vswitch.ovsschema
 if [ ${?} -ne 0 ] ; then
    echo "Creation of db and schema files failed"
    exit 1
 fi
 sudo ./ovsdb-server --remote=punix:$DB_SOCK --remote=db:Open_vSwitch,Open_vSwitch,manager_options --pidfile --detach
 if [ ${?} -ne 0 ] ; then
    echo "Starting of DB server failed"
    exit 1
 fi
 sleep 30
 #Start OVS
 echo "Start OVS"
 cd $VSPERF/src/ovs/ovs/utilities
 sudo ./ovs-vsctl --no-wait init
 sudo ./ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-lcore-mask=0xf
 sudo ./ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-socket-mem=1024
 sudo ./ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-init=true
 
 echo "Setting Huge pages on Node0"
 node0_pages=10
 node0_dir="/sys/devices/system/node/node0/hugepages/hugepages-1048576kB/nr_hugepages"
 node0_pages+=`cat $node0_dir`
 echo ${node0_pages} > ${node0_dir}

 echo "Setting Huge pages on Node1"
 node1_pages=10
 node1_dir="/sys/devices/system/node/node1/hugepages/hugepages-1048576kB/nr_hugepages"
 node1_pages+=`cat $node1_dir`
 echo ${node1_pages} > ${node1_dir}

 free_hp0=`cat /sys/devices/system/node/node0/hugepages/hugepages-1048576kB/free_hugepages`
 free_hp1=`cat /sys/devices/system/node/node1/hugepages/hugepages-1048576kB/free_hugepages`
 echo "Free Hugepages:${free_hp0}"
 echo "Free_Hugepages:${free_hp1}"

 cd $VSPERF/src/ovs/ovs/vswitchd
 sudo ./ovs-vswitchd unix:$DB_SOCK --pidfile --detach --log-file=$OVSLOGFILE
 if [ ${?} -ne 0 ] ; then
    echo "ovs-vswitchd not started"
    exit 1
 fi
 sleep 180
 #Configure the bridge
 echo "configure OVS Bridge"
 cd $VSPERF/src/ovs/ovs/utilities
 sudo ./ovs-vsctl add-br ovsbr0 -- set bridge ovsbr0 datapath_type=netdev
 sudo ./ovs-vsctl add-port ovsbr0 vhost-user1 -- set Interface vhost-user1 type=dpdkvhostuser
 sudo ./ovs-vsctl add-port ovsbr0 vhost-user2 -- set Interface vhost-user2 type=dpdkvhostuser
 sudo ./ovs-vsctl add-port ovsbr0 vhost-user3 -- set Interface vhost-user3 type=dpdkvhostuser
 sudo ./ovs-vsctl add-port ovsbr0 vhost-user4 -- set Interface vhost-user4 type=dpdkvhostuser
}
install_ovsdpdk
