#!/bin/bash

#############################################################################
#Copyright (c) 2015 Huawei Technologies Co.,Ltd and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################
set -e

source $WORKSPACE/ci/envs/packet_forwarding.sh
source $WORKSPACE/ci/envs/host-config

install_ovsdpdk()
{
 #Installing ovs dpdk using vsperf environment
 install_vsperf
 setup_ovsdpdk
}

setup_ovsdpdk()
{
 #Kill the ovsswitch and ovsdbserver
 killall ovsdb-server ovs-vswitchd
 rm -f /var/run/openvswitch/vhost-user*
 rm -f /etc/openvswitch/conf.db

 #Start database server
 export DB_SOCK=/var/run/openvswitch/db.sock
 ovsdb-tool create /etc/openvswitch/conf.db /usr/share/openvswitch/vswitch.ovsschema
 ovsdb-server --remote=punix:$DB_SOCK --remote=db:Open_vSwitch,Open_vSwitch,manager_options --pidfile --detach

 #Start OVS
 ovs-vsctl --no-wait init
 ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-lcore-mask=0xf
 ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-socket-mem=1024
 ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-init=true
 ovs-vswitchd unix:$DB_SOCK --pidfile --detach --log-file=$OVSLOGFILE

 #Configure the bridge
 ovs-vsctl add-br ovsbr0 -- set bridge ovsbr0 datapath_type=netdev
 ovs-vsctl add-port ovsbr0 vhost-user1 -- set Interface vhost-user1 type=dpdkvhostuser
 ovs-vsctl add-port ovsbr0 vhost-user2 -- set Interface vhost-user2 type=dpdkvhostuser
 ovs-vsctl add-port ovsbr0 vhost-user3 -- set Interface vhost-user3 type=dpdkvhostuser
 ovs-vsctl add-port ovsbr0 vhost-user4 -- set Interface vhost-user4 type=dpdkvhostuse
}
install_ovsdpdk
setup_ovsdpdk

